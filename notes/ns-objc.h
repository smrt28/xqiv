//
//  ns-objc.h
//  xqiv
//
//  Created by smrt on 4/9/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#ifndef xqiv_ns_objc_h
#define xqiv_ns_objc_h

namespace ns {
    template<typename>
    class object_t;
}

namespace nss {

    template<typename T_t>
    struct not_id_t {
        typedef T_t type_t;
    };
    
    template<>
    struct not_id_t<id> {
    private:
        struct xxx_t;
    public:
        typedef xxx_t type_t;
    };
    
    template<typename  T_t>
    id objc(const T_t &t) {
        return t.objc();
    }
    
    template<typename>
    id objc(id t) {
        return t;
    }
    
    template<typename T_t>
    T_t * objc(T_t *t) {
        return t;
    }
}

#endif
