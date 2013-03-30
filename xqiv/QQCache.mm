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

- (void)clearQueue {
    [_imageLoader incTime];
}

- (QQImageLoader *)loader {
    return _imageLoader;
}

@end

namespace s {
    size_t get_item_index(NSMutableDictionary * anItem) {
        NSNumber *n = [anItem objectForKey:@"index"];
        return [n longValue];
    }

    void Cache_t::insert(Dictionary_t &dict) {
        [qqCache clearQueue];
        Dictionary_t item;
        item.insert("item", dict);
        item.insert("visits", [NSNumber numberWithInt:0]);
        dict.insert("index", [NSNumber numberWithLong:array.size()]);
        array.push_back(item);
    }
    
    void Cache_t::go() {
        NSMutableDictionary * item = get(position);
        if (item && [item objectForKey:@"image"] == nil) {
            [qqCache clearQueue];
            [[qqCache loader] loadImage:item];
            return;
        }
        item = get_todo();
        if (item) {
            [[qqCache loader] loadImage:item];
        }
    }

    void Cache_t::positionChanged() {
        NSMutableDictionary * item = get(position);
        if (item) {
            [delegate showCachedImage:item];
            return;
        }
        go();
    }
    
    void Cache_t::next() {
        if (array.size() == 0) return;
        position = position + 1;
        if (position >= array.size()) position = 0;
        positionChanged();
    }
    
    void Cache_t::prev() {
        if (array.size() == 0) return;
        if (position == 0) {
            position = array.size() - 1;
        } else {
            position--;
        }
        positionChanged();
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
    
    
    void Cache_t::handleLoaded(NSMutableDictionary *anItem) {
        update(anItem);
        NSNumber *n = [anItem objectForKey:@"index"];
        if ([n intValue] == position) {
            [delegate showCachedImage:anItem];
        }
        go();
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