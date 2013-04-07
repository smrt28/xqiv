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

- (QQImageLoader *)loader {
    return _imageLoader;
}

- (BOOL)buzy {
    return [_imageLoader inProgress];
}

- (void)invalidate {
    [_imageLoader invalidate];
}

@end

namespace {
    bool isLoaded(NSMutableDictionary *item) {
        NSImage *img = [item objectForKey:@"image"];
        if (img) return true;
        return false;
    }

    int errorCode(NSMutableDictionary *item) {
        NSNumber *n = [item objectForKey:@"errorcode"];
        return [n intValue];
    }
}


namespace s {
    size_t get_item_index(NSMutableDictionary * anItem) {
        NSNumber *n = [anItem objectForKey:@"index"];
        return [n longValue];
    }

    void Cache_t::insert(Dictionary_t &dict) {
        array.push_back(dict);
    }
    
    void Cache_t::go() {
        if ([qqCache buzy]) return;
        NSMutableDictionary * item = get(position);
        if (item && [item objectForKey:@"image"] == nil) {
            [[qqCache loader] loadImage:item];
            return;
        }
        item = get_todo();
        if (item) {
            [[qqCache loader] loadImage:item];
        }
    }

    void Cache_t::positionChanged() {
        if (array.size() == 0) return;
        if ([qqCache buzy]) {
            nextPosition = position;
            return;
        }
        if (position >= array.size() || position < 0) {
            position = 0;
        }
        NSMutableDictionary * item = get(position);
        NSImage * img = [item objectForKey:@"image"];
        if (img) {
            [delegate showCachedImage:item];
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
        if (position <= 0) {
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
        return array[idx];
    }
    
    void Cache_t::update(NSMutableDictionary *anItem) {
         if (array.size() == 0) return;
        size_t idx = get_item_index(anItem);
        array.replace(idx, anItem);
    }
    
    
    void Cache_t::handleLoaded(NSMutableDictionary *anItem) {
        Dictionary_t item(anItem);
        int idx = item.value<int>(@"index");
        if (item.value<int>(@"errorcode")) {
            array.remove(idx);
            positionChanged();
            return;
        }
        update(anItem);
        

        if (idx == position) {
            [delegate showCachedImage:anItem];
        }
        if (nextPosition != -1) {
            position = nextPosition;
            nextPosition = -1;
            positionChanged();
            return;
        }

        logCache();
        go();
    }
    
    
    bool Cache_t::is_to_clear(size_t ofs) {
        int B = 3 ;
        int N = 15;
        
        if (B + N >= array.size() - 1) return false;
        
        int p = (int)position;
        
        int l = (p - B) % array.size();
        int r = (p + N) % array.size();
        int o = (int)ofs;
        
        bool rv;
        if (l < r) {
            if (o >= l && o <= r)
                    rv = false;
                else
                    rv = true;
        } else {
            if (o > r && o < l)
                rv = true;
            else
                rv = false;
        }

        return rv;
    }
    
    void Cache_t::logCache() {
        char buf[array.size() + 1];
        buf[array.size()] = 0;
        for (int i=0;i<array.size();i++) {
            if (isLoaded(get(i))) {
                buf[i] = '*';
                if (i == position) {
                    buf[i] = '#';
                }
            } else {
                buf[i] = '-';
                if (i == position) {
                    buf[i] = '?';
                }
            }
        }
        NSLog(@"%s", buf);
    }

    
    NSMutableDictionary * Cache_t::get_todo() {
        for(size_t i = 0;i<array.size();i++) {
            size_t ofs = (i + position) % array.size();
            NSMutableDictionary *rv = get(ofs);
            if (is_to_clear(ofs)) {
                bool b = isLoaded(rv);
                if (isLoaded(rv)) {
                    NSLog(@"clear: %zd", ofs);
                    [rv removeObjectForKey:@"image"];
                }
            }
        }
        
        
        for(size_t i = 0;i<array.size();i++) {
            size_t ofs = (i + position) % array.size();
            NSMutableDictionary *rv = get(ofs);
            if (is_to_clear(ofs) || isLoaded(rv)) {
                continue;
            }
            
            return rv;
        }
        return nil;
    }
}