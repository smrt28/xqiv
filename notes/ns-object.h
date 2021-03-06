//
//  ns-object.h
//  xqiv
//
//  Created by smrt on 4/8/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//
#ifndef xqiv_ns_object_h
#define xqiv_ns_object_h

#include "ns-objc.h"

namespace ns {
    template<typename>
    class object_t;
    
    namespace aux {
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
        

        template<typename Obj_t>
        struct is_objc_t {
            static inline Obj_t * get(id obj) { return obj; }
            typedef Obj_t * type_t;
        };

        template<> struct is_objc_t<int> {
            static inline int get(id obj) {
                return [obj intValue];
            }
            typedef int type_t;
        };
         

    }
    


    
    class handle_base_t {
        struct xxx_t {};
    public:
        typedef xxx_t key_t;
        typedef xxx_t item_t;
        
        item_t operator[](key_t) {
            NSLog(@"operator [] doesn't exist for the object!");
            return xxx_t();
        }
    };
    
    template<typename Object_t>
    class handle_t : public handle_base_t {
    public:
        explicit handle_t(Object_t *o) : o(o) {}
        Object_t * objc() { return o; }
    private:
        Object_t * o;
    };

    template<>
    class handle_t<id> : public handle_base_t {
    public:
        explicit handle_t(id o) : o(o) {}
        id objc() { return o; }
        
        template<typename Obj_t>
        typename aux::is_objc_t<Obj_t>::type_t as() {
            return aux::is_objc_t<Obj_t>::get(o);
        }
        
    private:
        id o;
    };

    
    template<>
    class handle_t<NSMutableDictionary> : public handle_base_t {
    public:
          
        typedef NSString * key_t;
        typedef id item_t;
        
        handle_t(NSMutableDictionary *o) : o(o) {}
        NSMutableDictionary * objc() { return o; }
        
        handle_t<item_t> operator[](key_t key) {
            return handle_t<item_t>([o objectForKey:key]);
        }
        
        template<typename var_t>
        void insert(key_t key, var_t var) {
            [o setObject: nss::objc(var) forKey:key];
        }
        
        template<typename>
        void insert(key_t key, int var) {
            [o setObject: [NSNumber numberWithInt:var] forKey:key];
        }
        
        void remove(key_t key) {
            [o removeObjectForKey:key];
        }
        
                
    private:
        NSMutableDictionary *o;
    };
    
    
    
    template<>
    class handle_t<NSMutableArray> : public handle_base_t {
    public:
        typedef int key_t;
        typedef id item_t;
        handle_t(NSMutableArray *o) : o(o) {}
        NSMutableArray * objc() { return o; }
        NSUInteger size() {
            return [o count];
        }
        
        handle_t<item_t> operator[](key_t idx) {
            return handle_t<item_t>([o objectAtIndex:idx]);
        }
        
        template<typename Obj_t>
        void push_back(object_t<Obj_t> itm) {
            [o addObject:itm.objc()];
        }
        template<typename Obj_t>
        void push_back(Obj_t *itm) {
            [o addObject:itm];
        }
        
        void remove(size_t idx) {
            [o removeObjectAtIndex:idx];
        }
        
        void clear() {
            [o removeAllObjects];
        }
        
    private:
        NSMutableArray *o;
    };

    
    

    namespace aux {
       
        template<typename Object_t>
        class handle_wrap_t {
        public:
            handle_wrap_t(Object_t *o) : o(o) {}
            handle_t<Object_t> * operator->() {
                return &o;
            }
            const handle_t<Object_t> * operator->() const {
                return &o;
            }
        
        private:
            handle_t<Object_t> o;
        };
    }
    
    template<typename Obj_t>
    class object_t {
    public:
        typedef Obj_t * type_t;
        typedef handle_t<typename handle_t<Obj_t>::item_t> item_rv_t;
        
        // explicit
        object_t() : o([[Obj_t alloc] init])
        {}
        
        object_t(type_t anObject) {
            o = [anObject retain];
        }
        
        template<typename T_t>
        object_t(handle_t<T_t> obj) {
            o = [obj.objc() retain];
        }
        
        ~object_t() {
            [o release];
        }
    
        object_t(const object_t &ro) {
            o = ro.objc();
            [o retain];
        }

        object_t & operator=(object_t<typename aux::not_id_t<Obj_t>::type_t> ro) {
            type_t tmp = o;
            o = ro.objc();
            [o retain];
            [tmp release];
            return *this;
        }

        object_t & operator=(object_t<id> &ro) {
            type_t tmp = o;
            o = aux::objc(ro);
            [o retain];
            [tmp release];
            return *this;
        }

 
        void reset(id anObject) {
            [anObject retain];
            [o release];
            o = anObject;
        }

        void reset() {
            [o release];
            o = nil;
        }
        
        type_t release() {
            type_t tmp = o;
            o = nil;
            [tmp autorelease];
            return tmp;
        }

        type_t objc() const { return o; }
        
        aux::handle_wrap_t<Obj_t> operator->() {
            return aux::handle_wrap_t<Obj_t>(o);
        }
        
        item_rv_t operator[](typename handle_t<Obj_t>::key_t key) {
            return handle_t<Obj_t>(o)[key];
        }

    private:
        type_t o;
    };
    
    
    template<>
    class object_t<id> {
    public:
        typedef id type_t;
        
        explicit object_t() : o(nil)
        {}
        
        object_t(type_t anObject) {
            if (anObject == nil) {
                o = nil;
                return;
            }
            o = [anObject retain];
        }
        
        // copy C'tor
        object_t(const object_t &ro) {
            o = ro.objc();
            [o retain];
        }
        
        template<typename Obj_t>
        object_t(object_t<const typename aux::not_id_t<Obj_t>::type_t> &ro) {
            o = ro.objc();
            [o retain];
        }
        
        
        ~object_t() {
            [o release];
        }
        
        
        template<typename Obj_t>
        object_t & operator=(const object_t<Obj_t> &ro) {
            type_t tmp = o;
            o = ro.objc();
            [o retain];
            [tmp release];
            return *this;
        }
        
        
        void reset(id anObject) {
            [anObject retain];
            [o release];
            o = anObject;
        }
        
        void reset() {
            [o release];
            o = nil;
        }
        
        id release() {
            type_t tmp = o;
            o = nil;
            [tmp autorelease];
            return tmp;
        }
        
        template <typename Rv_t>
        object_t<Rv_t> as() {
            Rv_t *rv = o;
            return object_t<Rv_t>(rv);
        }
        
        id objc() const { return o; }
        
    private:
        id o;
    };
         
}


#endif
