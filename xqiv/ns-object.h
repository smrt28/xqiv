//
//  ns-object.h
//  xqiv
//
//  Created by smrt on 4/8/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>

namespace ns {
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
        template<typename Object_t>
        class objc_helper_t {
        public:
            typedef Object_t * type_t;
            typedef Object_t type2_t;
            
            Object_t * operator()() {
                return [[Object_t alloc] init];
            }
        };
        
        template<>
        class objc_helper_t<id> {
        public:
            typedef id type_t;
            typedef void type2_t;
            id operator()() {
                return nil;
            }
        };
        
    }
    
    template<typename Obj_t>
    class raw_object_t {
    public:
        typedef typename aux::objc_helper_t<Obj_t>::type_t type_t;
        raw_object_t() :
            o(aux::objc_helper_t<Obj_t>()())
        {}
        
        raw_object_t(type_t anObject) {
            if (anObject == nil) {
                o = nil;
                return;
            }
            o = [anObject retain];
        }
        ~raw_object_t() {
            [o release];
        }
    
        
        
        raw_object_t(const raw_object_t &ro) {
            o = ro.objc();
            [o retain];
        }
        
        raw_object_t & operator=(raw_object_t<typename aux::objc_helper_t<Obj_t>::type2_t > &ro) {
            type_t tmp = o;
            o = ro.objc();
            [o retain];
            [tmp release];
            return *this;
        }

        raw_object_t & operator=(const raw_object_t<id> &ro) {
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
    
 
    
    
    
    template<typename Object_t>
    class object_t {
    public:
        object_t() {}
        
        template<typename Type_t>
        object_t(Type_t anObject) : o(anObject) {}
        
        Object_t * objc() { return o.objc(); }
        void reset() { o.reset(); }
        Object_t * release() { return o.release(); }
        
    private:
        raw_object_t<Object_t> o;

    };
}



