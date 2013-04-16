//
//  ns-dict.h
//  xqiv
//
//  Created by smrt on 4/16/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#ifndef xqiv_ns_dict_h
#define xqiv_ns_dict_h

#include "as.h"

namespace ns {
    class dict_t : public ns::base_t<NSMutableDictionary> {
    public:
        typedef NSMutableDictionary objc_type_t;
        
        dict_t() {}
        dict_t(NSMutableDictionary *dict) :
            ns::base_t<NSMutableDictionary>(dict)
        {}
        
        template<typename T_t>
        void insert(NSString *key, T_t value) {
            [o setObject: nss::objc(value) forKey:key];
        }
        
        nss::id_t operator[](NSString *key) {
            return nss::id_t([o objectForKey: key]);
        }
        
        void remove(NSString *key) {
            [o removeObjectForKey: key];
        }
        
        void clear() {
            [o removeAllObjects];
        }
    };
}


#endif
