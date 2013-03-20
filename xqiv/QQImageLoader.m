//
//  QQImageLoader.m
//  xqiv
//
//  Created by smrt on 3/19/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQImageLoader.h"
#include <openssl/sha.h>
#include <CommonCrypto/CommonDigest.h>

@implementation QQImageLoader


-(id)initWithCallback:(SEL)callback target:(id)obj {
    self = [super init];
    _end = NO;
    _callback = callback;
    _target = obj;
    _thread = [NSThread currentThread];
    return self;
}

- (void)dealloc {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self];
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




- (void)loadImageAsync:(NSString *)filename {
    @autoreleasepool {
        
    NSMutableDictionary *ret = nil;
    NSImage *img;
    NSString *sha1 = nil;
        
    @try {
        NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath: filename];
        if (fh) {
            NSData *data = [fh readDataOfLength:1024 * 1024 * 32];
            NSMutableData *hashData = [NSMutableData dataWithLength:SHA_DIGEST_LENGTH];
            
            const char *b = [data bytes];
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
        }
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
    if (sha1) [ret setObject:sha1 forKey:@"sha1"];
    
    [_target performSelector:_callback onThread:_thread withObject:ret waitUntilDone:NO];
    }
}

- (void)loadImage:(NSString *)filename {
    [self performSelector:@selector(loadImageAsync:) onThread:self withObject:filename waitUntilDone:NO];
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
