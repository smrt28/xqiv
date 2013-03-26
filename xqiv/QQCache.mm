//
//  QQCache.m
//  xqiv
//
//  Created by smrt on 3/23/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQCache.h"

@implementation QQCache

- (id)initWithCache:(s::Cache_t *)cache {
    self = [super init];
    _cache = cache;
    _imageLoader = [QQImageLoader new];
    [_imageLoader setDelegate: self];
    [_imageLoader start];
    return self;
}

- (void)dealloc {
    [_imageLoader release];
    [super dealloc];
}

- (void)imageLoaded:(NSMutableDictionary *)obj {
    _cache->handleLoaded(obj);
}

@end

namespace s {
    size_t get_item_index(NSMutableDictionary * anItem) {
        NSNumber *n = [anItem objectForKey:@"index"];
        return [n longValue];
    }

    void Cache_t::insert(Dictionary_t &dict) {
        Dictionary_t item;
        item.insert("item", dict);
        item.insert("visits", [NSNumber numberWithInt:0]);
        dict.insert("index", [NSNumber numberWithLong:array.size()]);
        array.push_back(item);
    }

    
    NSMutableDictionary * Cache_t::get() {
        return get(position);
    }
    
    NSMutableDictionary * Cache_t::get(size_t idx) {
        if (array.size() == 0) return nil;
        Dictionary_t dict(array[idx % array.size()]);
        return dict["item"];
    }
    
    void Cache_t::update(NSMutableDictionary *anItem) {
        if (array.size() == 0) return;
        size_t idx = get_item_index(anItem);
        Dictionary_t dict(array[idx]);
        dict.remove("item");
        dict.insert("item", anItem);
    }
    
    id Cache_t::operator[](NSString *s) {
        if (array.size() == 0) return nil;
        return [get() objectForKey:s];
    }
    
    void Cache_t::handleLoaded(NSMutableDictionary *item) {
        
    }
    
    NSMutableDictionary * Cache_t::get_todo() {
        for(size_t i = 0;i<array.size();i++) {
            NSMutableDictionary *rv = get(i + position);
            if ([rv objectForKey:@"image"]) {
                continue;
            }
            return rv;
        }
        return nil;
    }
}