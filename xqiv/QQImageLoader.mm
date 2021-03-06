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
#import "CImageUtils.h"
#import "CHash.h"
#import "QQStruct.h"

#import "ns-dict.h"
#import "ns-grcontext.h"

@implementation QQImageLoaderCBridge
-(id)init {
    self = [super init];
    _c = 0;
    return self;
}

- (void)setC:(s::ImgLoaderListener_t *)c {
    _c = c;
}

- (void)imageLoaded:(NSMutableDictionary *)obj {
    if (!_c) return;
    _c->loaded(obj);
}

@end


@implementation QQImageLoader


-(id)init {
    self = [super init];

  //  [self setThreadPriority:<#(double)#>]
    _end = NO;
    _inProgress = NO;
    _thread = [NSThread currentThread];
    double p = [_thread threadPriority];
    [self setThreadPriority: p+0.1];
    _delegate = nil;

    return self;
}

- (void)dealloc {
    [_delegate release];
    _delegate = nil;
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
    ns::dict_t item(anItem);
    ns::dict_t ret;
    ret.insert(@"filename", item[@"filename"]);
    ret.insert(@"errorcode", 0);
    ret.insert(@"userdata", item[@"userdata"]);
    return ret.release();
}

- (void)loadImageAsync:(NSMutableDictionary *)anItem {
    
    ns::dict_t item(anItem);

    bool sha1_only = false;

    @autoreleasepool {
    
    NSString *filename = item[@"filename"];
    ns::dict_t useredata(item[@"userdata"].as<NSMutableDictionary>());
    ns::dict_t ret([self createResponse:anItem]);

    NSImage *img = nil, *original = nil;
    NSString *sha1 = nil;
    NSRect screenFrame = [[NSScreen mainScreen] visibleFrame];
        
    @try {
        NSFileHandle *fh = [NSFileHandle fileHandleForReadingAtPath: filename];
        if (fh) {
            NSData *data = [fh readDataOfLength:1024 * 1024 * 32];            
            sha1 = s::hash::hex(s::hash::sha1(data));
            original = [[[NSImage alloc] initWithData:data] autorelease];
            NSSize osize = s::img::pixelSize(original);
            ret.insert(@"originalsize", [QQNSSize sizeWithNSSize:osize]);
            ret.insert(@"data", data);



            QQNSSize *tmpSize = useredata[@"size"].as<QQNSSize>();
            if (tmpSize) {
                NSSize reqSize = [tmpSize size];
                img = s::img::fitSize(original, reqSize);
                [img setCacheMode:NSImageCacheNever];
            } else {
                sha1_only = true;
            }
        }
    }
    @catch (NSException *exception) {
        img = nil;
        sha1_only = false;
    }
    
    if (img) {
        ret.insert(@"image", img);
    } else {
        if (!sha1_only) {
            ret.insert(@"errorcode", 1);
        }
    }
        
    if (sha1)
        ret.insert(@"sha1", sha1);
        
    [self performSelector:@selector(handleImageLoaded:)
                 onThread:_thread withObject:ret.release() waitUntilDone:NO];
        
    } // @autoreleasepool
}

- (void)handleImageLoaded:(NSMutableDictionary *)result {
    _inProgress = NO;
    [_delegate imageLoaded: result];
}

- (BOOL)loadImage:(NSString *)filename userData:(id)data {
    
    if (_inProgress)
        return NO;
    _inProgress = YES;
    
    ns::dict_t dd;
    dd.insert(@"userdata", data);
    dd.insert(@"filename", filename);
    

    [self performSelector:@selector(loadImageAsync:)
                 onThread:self withObject:dd.objc() waitUntilDone:NO];
    
    return YES;
}


- (void)joinAsync {
    _end = YES;
}

- (void)nop {
}

- (void)join {
    [self performSelector:@selector(joinAsync) onThread:self withObject:nil waitUntilDone:YES];
}

- (void)ensureWaiting {
    [self performSelector:@selector(nop) onThread:self withObject:nil waitUntilDone:YES];
}

- (BOOL)inProgress {
    return _inProgress;
}

- (void)main
{
    @autoreleasepool {
        NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
        NSPort *port = [NSPort port];
        [runLoop addPort:port forMode:NSDefaultRunLoopMode];
        
        while(!_end) {
            [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
}



@end
