//
//  ns-array.h
//  xqiv
//
//  Created by smrt on 4/13/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#ifndef xqiv_ns_array_h
#define xqiv_ns_array_h

#include "as.h"


namespace ns {
    
    class array_t : public ns::base_t<NSMutableArray> {
    public:
        typedef NSMutableArray objc_type_t;
        
        array_t() {}
        
        explicit array_t(NSMutableArray *anArray) :
            ns::base_t<NSMutableArray>(anArray) {}
        
        nss::id_t operator[](size_t idx) {
            return nss::id_t([o objectAtIndex:idx]);
        }
        
        template<typename T_t>
        void push_back(T_t t) {
            [o addObject:nss::objc(t)];
        }
        
        void clear() {
            [o removeAllObjects];
        }
        
        size_t size() {
            return [o count];
        }
        
        void remove(size_t idx) {
            [o removeObjectAtIndex:idx];
        }
        
        void pop() {
            [o removeLastObject];
        }
    };
}


#endif
