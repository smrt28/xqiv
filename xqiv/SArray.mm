//
//  SArray.m
//  xqiv
//
//  Created by smrt on 3/23/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SArray.h"
#import "SDictionary.h"

namespace s {
    void Array_t::push_back(id obj) {
        [array addObject: obj];
    }

    id Array_t::operator[](size_t idx) {
        id rv = [array objectAtIndex:idx];
        return fixRetVal(idx, rv);
    }
    
    id Array_t::at(size_t idx) {
        if (idx >= size()) return nil;
        id rv = [array objectAtIndex:idx];
        return fixRetVal(idx, rv);
    }
    
    void Array_t::push_back(Dictionary_t &dict) {
        push_back(dict.objc());
    }
    
    id ArrayWithNumbers_t::fixRetVal(size_t idx, id rv) {
        Dictionary_t dict(rv);
        dict.insert(@"index", int(idx));
        return dict.release();
    }
}