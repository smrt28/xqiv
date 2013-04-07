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
        
        void remove(int idx) {
            [array removeObjectAtIndex:idx];
        }
        
        void clear() {
            [array removeAllObjects];
        }
        
        void replace(size_t idx, id val) {
            [array replaceObjectAtIndex:idx withObject:val];
        }
        
        virtual id fixRetVal(size_t idx, id rv) {
            return rv;
        }
        
    private:
        NSMutableArray *array;
    };
    
    
    class ArrayWithNumbers_t : public Array_t {
    public:
        virtual id fixRetVal(size_t idx, id rv);

        
    };
    
}