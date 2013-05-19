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
        typedef Object_t * value_t;
        typedef ns::array_t::objc_type_t objc_type_t;

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

        Object_t * at(size_t idx) {
            if (size() == 0) return nil;
            return a[idx % size()];
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

        objc_type_t * release() {
            return a.release();
        }
        
        objc_type_t * release(objc_type_t *ob) {
            return a.release(ob);
        }

    private:
        ns::array_t a;
    };
}


#endif
