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
        return [array objectAtIndex:idx];
    }
    
    id Array_t::at(size_t idx) {
        if (idx >= size()) return nil;
        return [array objectAtIndex:idx];
    }
    
    void Array_t::push_back(Dictionary_t &dict) {
        push_back(dict.objc());
    }

}