//
//  ns-object.h
//  xqiv
//
//  Created by smrt on 4/8/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>

namespace ns {
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
        
        template<typename Object_t>
        class objc_creator_t {
        public:
            typedef Object_t * type_t;
            Object_t * operator()() {
                return [[Object_t alloc] init];
            }
        };
        template<>
        class objc_creator_t<id> {
        public:
            typedef id type_t;
            id operator()() {
                return nil;
            }
        };
    }
    
    template<typename>
    class raw_object_t;

    
    template<typename Object_t>
    class handle_t {
    public:
        explicit handle_t(Object_t *o) : o(o) {}
        Object_t * objc() { return o; }
        void reset(Object_t *anObject = nil) {
            o = anObject;
        }
        void reset(raw_object_t<Object_t> ro) {
            o = ro.objc();
        }
    private:
        Object_t * o;
    };
    
    template<>
    class handle_t<id> {
    public:
        explicit handle_t(id o) : o(o) {}
        
        template<typename Type_t>
        Type_t * as() { return o; }
        
        template<typename Object_t>
        void reset(Object_t *anObjcet = nil) {
            o = anObjcet;
        }

        template<typename Object_t>
        void reset(raw_object_t<Object_t> ro) {
            o = ro.objc();
        }
        
        id objc() const { return o; }
    private:
        id o;
    };


    namespace aux {
        template<typename  T_t>
        id objc(const T_t &t) {
            return t.objc();
        }
    }
    
    template<typename Obj_t>
    class object_t {
    public:
        typedef typename aux::objc_creator_t<Obj_t>::type_t type_t;
        
        // explicit
        object_t() : o([[Obj_t alloc] init])
        {}
        
        object_t(type_t anObject) {
            if (anObject == nil) {
                o = nil;
                return;
            }
            o = [anObject retain];
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



