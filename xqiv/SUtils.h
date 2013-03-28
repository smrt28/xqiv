//
//  SUtils.h
//  xqiv
//
//  Created by smrt on 3/23/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#ifndef xqiv_SUtils_h
#define xqiv_SUtils_h

namespace s {
namespace noncopyable_  // protection from unintended ADL
{
    class noncopyable
    {
    protected:
        noncopyable() {}
        ~noncopyable() {}
    private:  // emphasize the following members are private
        noncopyable( const noncopyable& );
        const noncopyable& operator=( const noncopyable& );
    };
}

typedef noncopyable_::noncopyable noncopyable;

    class AutoRelease_t {
    public:
        AutoRelease_t(id obj) : obj(obj) {}
        ~AutoRelease_t() { [obj release]; }
        id get() { return obj; }
        void forget() { obj = nil; }
    private:
        id obj;
    };
    
}

#endif
