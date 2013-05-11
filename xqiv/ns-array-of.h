//
//  ns-array-of.h
//  xqiv
//
//  Created by smrt on 5/11/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#ifndef xqiv_ns_array_of_h
#define xqiv_ns_array_of_h

#include "ns-array.h"

namespace ns {
    template<typename Object_t>
    class array_of_t {
    public:
        array_of_t() {}
        explicit array_of_t(NSMutableArray *anArray) : a(anArray)
        {}

        void push_back(Object_t *o) {
            a.push_back(o);
        }

        void clear() {
            a.clear();
        }

        Object_t * operator[](size_t idx) {
            return a[idx];
        }

        size_t size() {
            return a.size();
        }

        
        void replace(size_t idx, Object_t *o) {
            a.release(idx, o);
        }

        void remove(size_t idx) {
            a.remove(idx);
        }
        

    private:
        ns::array_t a;
    };
}


#endif
