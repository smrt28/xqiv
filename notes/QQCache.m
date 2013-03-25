//
//  QQCache.m
//  xqiv
//
//  Created by smrt on 3/22/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQCache.h"

@implementation QQCacheItemWrap

- (void)dealloc {
    @synchronized(_lock) {
        NSString *key = [_item objectForKey:@"key"];
        if ([_db objectForKey:key] == nil) {
            [_db setObject:_item forKey:key];
        }
    }
    [_db release];
    [_item release];
    [_lock release];
    [super dealloc];
}

- (id)initWithDb:(NSMutableDictionary *)db lock:(NSObject *)aLock
      item:(NSMutableDictionary *)anItem
{
    @synchronized(_lock) {
        _db = db;
        _item = anItem;
        _lock = aLock;
        [_db retain];
        [_item retain];
        [_lock retain];
    }
    return self;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
    [anInvocation setTarget:_item];
    [anInvocation invoke];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector {
    return [_db methodSignatureForSelector:aSelector];
}

@end

@implementation QQCache

- (id)init {
    [super init];
    _db = [[NSMutableDictionary alloc] init];
    _lock = [[NSObject alloc] init];
    return self;
}

- (void)dealloc {
    [_db release];
    [_lock release];
    [super dealloc];
}

- (void)insertItem:(NSMutableDictionary *)db {
    NSString * key = [db objectForKey:@"key"];
    if (!key) return;
    @synchronized(_lock) {
        [_db setObject:db forKey:key];
    }
}

- (QQCacheItemWrap *)getItem:(NSString *)key {
    QQCacheItemWrap *rv;
    @synchronized(_lock) {
        NSMutableDictionary *anItem = [_db objectForKey:key];
        if (!anItem) return nil;
        [anItem retain];
        [_db removeObjectForKey:key];
        rv = [[QQCacheItemWrap alloc]
          initWithDb:_db lock:_lock item:anItem];
        [anItem release];
    }
    return rv;
}

@end
