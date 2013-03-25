//
//  SArray.h
//  xqiv
//
//  Created by smrt on 3/23/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SUtils.h"
namespace s {
    
    class Dictionary_t;
    
    
    class Array_t : s::noncopyable {
    public:
        Array_t() : array([NSMutableArray new])
        {}
        
        Array_t(NSMutableArray *array) : array(array) {
            [array retain];
        }
        
        ~Array_t() {
            [array release];
        }
        
        void push_back(Dictionary_t &);
        void push_back(id obj);
        
        id operator[](size_t);
        id at(size_t);
        
        size_t size() {
            return [array count];
        }
        
        void clear() {
            [array removeAllObjects];
        }
        
    private:
        NSMutableArray *array;
    };
}