//
//  QQImageLoader.m
//  xqiv
//
//  Created by smrt on 3/19/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQImageLoader.h"

@implementation QQImageLoader


-(id)initWithCallback:(SEL)callback target:(id)obj {
    self = [super init];
    _jobs = [[NSMutableArray alloc] init];
    _condition = [[NSCondition alloc] init];
    _lock = [[NSLock alloc] init];
    _end = NO;
    _callback = callback;
    _target = obj;
    _endCondition = nil;
    _thread = [NSThread currentThread];
    return self;
}

- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
    [_condition release];
    [_jobs release];
    [_lock release];
    [super dealloc];
}

+ (QQImageLoader *)loader:(SEL)callback target:(id)obj {
    return [[[QQImageLoader alloc] initWithCallback:callback target:obj] autorelease];
}

- (void)asyncNotify:(NSNotification *)notification {
    id a = notification.object;
    NSMutableDictionary *obj = notification.object;
    NSString * filename = [obj objectForKey:@"filename"];
    NSImage * image = [[[obj objectForKey:@"image"] retain] autorelease];
    [_target performSelector:_callback withObject:filename withObject:image];

}

- (void)task {
    [_lock lock];
    NSMutableDictionary *obj = [[[_jobs objectAtIndex:0] retain] autorelease];
    [_jobs removeObjectAtIndex:0];
    [_lock unlock];
    
    NSMutableDictionary *ret = nil;
    NSString * filename = [obj objectForKey:@"filename"];
    NSImage *img;

    @try {
        img = [[[NSImage alloc] initWithContentsOfFile: filename] autorelease];
    }
    @catch (NSException *exception) {
        img = nil;
    }
    
    ret = [NSMutableDictionary dictionary];
    if (img) {
        [ret setObject:img forKey:@"image"];
    } else {
        [ret setObject:@"error: file does not exist" forKey:@"error-message"];
    }
    [ret setObject:filename forKey:@"filename"];
    
    [_target performSelector:_callback onThread:_thread withObject:ret waitUntilDone:NO];
}

-(void)insert:(NSDictionary *)obj {
    [_lock lock];
    [_jobs addObject:obj];
    [_lock unlock];
    [_condition signal];
}

-(void)insertImageTask:(NSString *)filename {
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    [ret setObject:filename forKey:@"filename"];
    [self insert:ret];
}

- (void)main
{
    [_condition lock];
    while(!_end) {
        [_condition wait];
        @autoreleasepool {
            [self task];
        }
    }
    [_condition unlock];
    [_endCondition signal];
}

- (void)join {
    _endCondition = [[[NSCondition alloc] init] autorelease];
    [_endCondition lock];
        _end = YES;
        [_condition signal];
        [_endCondition wait];
    [_endCondition unlock];
}


@end
