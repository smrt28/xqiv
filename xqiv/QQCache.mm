//
//  QQCache.m
//  xqiv
//
//  Created by smrt on 3/23/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQCache.h"

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
        if (array.size() == 0) return nil;
        Dictionary_t dict(array[position]);
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
}