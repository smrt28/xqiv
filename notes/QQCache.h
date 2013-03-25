//
//  QQCache.h
//  xqiv
//
//  Created by smrt on 3/22/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QQCacheItemWrap : NSProxy {
    NSMutableDictionary *_db;
    NSDictionary *_item;
    NSObject *_lock;
}
//– (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector;

@end

@interface QQCache : NSObject {
    NSMutableDictionary *_db;
    NSObject *_lock;
}

- (void)insertItem:(NSMutableDictionary *)db;
- (QQCacheItemWrap *)getItem:(NSString *)key;

@end
