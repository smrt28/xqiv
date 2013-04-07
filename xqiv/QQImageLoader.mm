//
//  QQImageLoader.m
//  xqiv
//
//  Created by smrt on 3/19/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//


#include <openssl/sha.h>
#include <CommonCrypto/CommonDigest.h>
#import "QQImageLoader.h"
#import "SDictionary.h"
#import "CImageUtils.h"
#import "CHash.h"

@implementation QQImageLoader


-(id)init {
    self = [super init];
    _end = NO;
    _inProgress = NO;
    _invalied = NO;
    _thread = [NSThread currentThread];
    _delegate = nil;

    return self;
}

- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [_delegate release];
    [nc removeObserver:self];
    [self join];
    [super dealloc];
}

- (void)setDelegate:(id)aDelegate {
    [_delegate release];
    _delegate = aDelegate;
    [_delegate retain];
}

- (id)delegate {
    return _delegate;
}



+ (QQImageLoader *)loader {
    return [[[QQImageLoader alloc] init] autorelease];
}


- (NSMutableDictionary *)createResponse:(NSMutableDictionary *)anItem  {
    s::Dictionary_t item(anItem);
    s::Dictionary_t ret;
    ret.insert(@"index", item[@"index"]);
    ret.insert(@"filename", item[@"filename"]);
    ret.insert(@"errorcode", 0);
    return ret.release();
}

- (void)loadImageAsync:(NSMutableDictionary *)anItem {
    
    s::Dictionary_t item(anItem);
    
    @autoreleasepool {
    
    NSString *filename = item["filename"];
        
    s::Dictionary_t ret([self createResponse:anItem]);

    NSImage *img = nil;
    NSString *sha1 = nil;
    NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
        
    @try {
        NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath: filename];
        if (fh) {
            NSData *data = [fh readDataOfLength:1024 * 1024 * 32];            
            sha1 = s::hash::hex(s::hash::sha1(data));
            img = [[[NSImage alloc] initWithData:data] autorelease];
            img = s::img::fitScreen(img);
        }
    }
    @catch (NSException *exception) {
        img = nil;
    }
    
    if (img) {
        ret.insert(@"image", img);
    } else {
        ret.insert(@"errorcode", 1);
    }
        
    if (sha1)
        ret.insert(@"sha1", sha1);
        
    [self performSelector:@selector(handleImageLoaded:)
                 onThread:_thread withObject:ret.release() waitUntilDone:NO];
        
    } // @autoreleasepool
}

- (void)handleImageLoaded:(NSMutableDictionary *)result {
    _inProgress = NO;
    if (_invalied) {
        _invalied = NO;
        return;
    }
    [_delegate imageLoaded: result];
}

- (BOOL)loadImage:(NSMutableDictionary *)item {
    if (_inProgress)
        return NO;
    _inProgress = YES;
    [self performSelector:@selector(loadImageAsync:) onThread:self withObject:item waitUntilDone:NO];
    return YES;
}


- (void)joinAsync {
    _end = YES;
}

- (void)join {
    [self performSelector:@selector(joinAsync) onThread:self withObject:nil waitUntilDone:YES];

}

- (BOOL)inProgress {
    return _inProgress;
}

- (void)invalidate {
    if (_inProgress)
        _invalied = YES;
}

- (void)main
{
    @autoreleasepool {
    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    NSPort *port = [NSPort port];
    [runLoop addPort:port forMode:NSDefaultRunLoopMode];
    
    while(!_end) {
        BOOL r = [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    }
}



@end
