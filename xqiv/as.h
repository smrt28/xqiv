//
//  as.h
//  xqiv
//
//  Created by smrt on 4/13/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#ifndef xqiv_as_h
#define xqiv_as_h

namespace nss {
    
    namespace aux {
        // sfinae
        template<typename T_t>
        struct has_objc_type_t {
            typedef char yes_t[1];
            typedef char no_t[2];
            
            template<typename C_t>
            static yes_t & test(typename C_t::objc_type_t *);
            
            template<typename>
            static no_t & test(...);
            
            static const bool value = sizeof( test<T_t>(0) ) == sizeof(yes_t);
        };
    
        template<typename T_t, bool b>
        struct x_make_objc_type_t;
        
        template<typename T_t>
        struct x_make_objc_type_t<T_t, true> {
            typedef T_t type_t;
        };
        template<typename T_t>
        struct x_make_objc_type_t<T_t, false> {
            typedef T_t * type_t;
        };
        
        template<typename T_t>
        struct ns_translate_t {
            typedef typename x_make_objc_type_t<T_t, has_objc_type_t<T_t>::value >::type_t type_t;
        };
    } // namespace aux
    
    

    template<typename T_t> struct translate_t {
        typedef typename aux::ns_translate_t<T_t>::type_t type_t;
    };
    template<> struct translate_t<id> { typedef id type_t; };
    template<> struct translate_t<int> { typedef int type_t; };
    template<> struct translate_t<long> { typedef long type_t; };
 
    
    
    template<typename T_t> T_t * objc(T_t *t) { return t; }
    
    inline NSNumber * objc(int n) { return [NSNumber numberWithInt:n];  }
    inline NSNumber * objc(long n) { return [NSNumber numberWithLong:n];  }
    
//    template<typename T_t>
//    inline x_make_objc_type_t<T_t>::type_t::objc_type_t;


    
    
    class id_t {
    public:
        
        id_t(id anObject) : o([anObject retain]) {}
        id_t(const id_t &p) {
            o = p.o;
            [o retain];
        }
        ~id_t() { [o release]; }
        
        template<typename T_t>
        typename translate_t<T_t>::type_t as() {
            return typename translate_t<T_t>::type_t(o);
        }
        
        template<typename T_t>
        id_t operator=(T_t t);
        
        operator id() {
            return o;
        }
        
    private:
        id o;
    };

    template<> inline int id_t::as<int>() {
        return [o intValue];
    }
    
    
    template <typename T_t>
    class object_t {
    public:
        object_t() : o([[T_t alloc] init]) {}
        object_t(const object_t &p) {
            o = p.o;
            [o retain];
        }
        
        object_t(T_t *o) : o(o) {
            [o retain];
        }
        
        ~object_t() {
            [o release];
        }
        
        object_t & operator=(T_t *t) {
            [t retain];
            [o release];
            o = t;
            return *this;
        }
        
        object_t & operator=(const object_t &h) {
            [h.o retain];
            [o release];
            o = h.o;
            return *this;
        }
        
        T_t * release() {
            T_t * tmp = o;
            o = nil;
            return [tmp autorelease];
        }
        
        operator T_t *() {
            return o;
        }
        
    private:
        T_t * o;
    };
   
}

namespace ns {
    template<typename T_t>
    class base_t {
    public:
        base_t() {}
        base_t(T_t *t) : o(t) {}
        T_t * objc() { return o; }
        
        T_t * release() {
            return o.release();
        }
        
    protected:
        nss::object_t<T_t> o;
    };
}

namespace nss {
    template<typename T_t>
    T_t * objc(ns::base_t<T_t> &o) { return o.objc(); }
    inline id objc(nss::id_t &o) {
        return o;
    }
}

#endif
