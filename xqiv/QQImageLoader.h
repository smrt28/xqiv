//
//  QQImageLoader.h
//  xqiv
//
//  Created by smrt on 3/19/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol QQImageLoaderProtocol<NSObject>
    - (void)imageLoaded:(NSMutableDictionary *)obj;
@end

@interface QQImageLoader : NSThread {
    BOOL _end;
    id _target;
    NSThread *_thread;
    id<QQImageLoaderProtocol> _delegate;
    int _time;
    NSObject *_lock;
}



+ (QQImageLoader *)loader;
- (void)loadImage:(NSDictionary *)filename;
- (void)join;
- (void)setDelegate:(id<QQImageLoaderProtocol>)delegate;
- (id)delegate;
- (void)incTime;

@end
