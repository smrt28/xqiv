//
//  ns-grcontext.h
//  xqiv
//
//  Created by smrt on 4/24/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#ifndef xqiv_ns_grcontext_h
#define xqiv_ns_grcontext_h
namespace ns {
class grcontext_autosave_t {
public:
    grcontext_autosave_t() :
        context([NSGraphicsContext currentContext])
    {
        [context saveGraphicsState];
    }
    
    ~grcontext_autosave_t() {
        [context restoreGraphicsState];
    }
private:
    NSGraphicsContext *context;
};
}

#endif
