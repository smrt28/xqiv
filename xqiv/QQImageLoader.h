//
//  QQImageLoader.h
//  xqiv
//
//  Created by smrt on 3/19/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface QQImageLoader : NSThread {
    BOOL _end;
    SEL _callback;
    id _target;
    NSThread *_thread;
    NSMutableDictionary *_cache;
}

+ (QQImageLoader *)loader:(SEL)callback target:(id)obj;
- (void)loadImage:(NSMutableDictionary *)filename;
- (void)join;


@end
