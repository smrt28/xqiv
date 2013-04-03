//
//  QQImageLoader.m
//  xqiv
//
//  Created by smrt on 3/19/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQImageLoader.h"
#import "SDictionary.h"
#import "CImageUtils.h"
#include <openssl/sha.h>
#include <CommonCrypto/CommonDigest.h>

@implementation QQImageLoader


-(id)init {
    self = [super init];
    _end = NO;
    _lock = [[NSObject alloc] init];
    _thread = [NSThread currentThread];
    _delegate = nil;

    return self;
}

- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [_delegate release];
    [_lock release];
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

- (int)incTime {
    @synchronized(_lock) {
        _time++;
        return _time;
    }
}


+ (QQImageLoader *)loader {
    return [[[QQImageLoader alloc] init] autorelease];
}


- (void)loadImageAsync:(NSMutableDictionary *)anItem {
    
    s::Dictionary_t item(anItem);
    NSNumber *index = item["index"];
    int aTime;
    @synchronized(_lock) {
        aTime = _time;
        NSNumber *t = [anItem objectForKey:@"time"];
        int objTime = [t intValue];
       // NSLog(@"time=%d objtime=%d", _time, objTime);
        if (objTime != _time) return;
    }
  
    @autoreleasepool {
    
    NSString *filename = item["filename"];
        
    NSMutableDictionary *ret = [NSMutableDictionary dictionary];
    [ret setObject:[NSNumber numberWithInt:aTime] forKey:@"time"];
    NSImage *img;
    NSString *sha1 = nil;
    NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
        
    @try {
        NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath: filename];
        if (fh) {
            NSData *data = [fh readDataOfLength:1024 * 1024 * 32];

            NSMutableData *hashData =
                [NSMutableData dataWithLength:SHA_DIGEST_LENGTH];

            const char *b = (const char *)[data bytes];
            CC_LONG len = (CC_LONG)[data length];
            unsigned char digest[CC_SHA1_DIGEST_LENGTH];
            CC_SHA1_CTX ctx;
            CC_SHA1_Init(&ctx);
            CC_SHA1_Update(&ctx, b, len);
            CC_SHA1_Final(digest, &ctx);
            
            char digestStr[CC_SHA1_DIGEST_LENGTH * 2 + 1];
            digestStr[CC_SHA1_DIGEST_LENGTH * 2] = 0;
            static const char *hex = "0123456789abcdef";
        
            char *c = digestStr;
            for (int i = 0; i<CC_SHA1_DIGEST_LENGTH; i++) {
                *c = hex[digest[i] >> 4]; c++;
                *c = hex[digest[i] & 0xf]; c++;
            }
            
            sha1 = [NSString stringWithUTF8String:digestStr];
            img = [[[NSImage alloc] initWithData:data] autorelease];
            img = s::img::fitScreen(img);
        }
    }
    @catch (NSException *exception) {
        img = nil;
    }
    
    
    [ret setObject:[NSNumber numberWithLong:[index longValue]] forKey:@"index"];

    if (img) {
        [ret setObject:img forKey:@"image"];
        [ret setObject:[NSNumber numberWithLong:s::img::msize(img)] forKey:@"msize"];
        
    } else {
        [ret setObject:@"error: file does not exist" forKey:@"error-message"];
    }
        
    [ret setObject:filename forKey:@"filename"];
    if (sha1)
        [ret setObject:sha1 forKey:@"sha1"];

   // NSLog(@"LOADED: %@", filename);
        
    [self performSelector:@selector(handleImageLoaded:)
                 onThread:_thread withObject:ret waitUntilDone:NO];
        
    } // @autoreleasepool
}

- (void)handleImageLoaded:(NSMutableDictionary *)result {
    @synchronized(_lock) {
        NSNumber *n = [result objectForKey:@"time"];
        if ([n intValue] != _time) {
            NSLog(@"Old async image skipped");
            return;
        }
    }
    
    [_delegate imageLoaded: result];
}

- (void)loadImage:(NSMutableDictionary *)item {
    @synchronized(_lock) {
    [item setObject:[NSNumber numberWithInt:_time] forKey:@"time"];
    }
    [self performSelector:@selector(loadImageAsync:) onThread:self withObject:item waitUntilDone:NO];
}


- (void)joinAsync {
    _end = YES;
}

- (void)join {
    [self performSelector:@selector(joinAsync) onThread:self withObject:nil waitUntilDone:YES];

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
