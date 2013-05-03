//
//  CImageUtils.h
//  xqiv
//
//  Created by smrt on 3/25/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>



namespace s {
namespace img {
    size_t msize(NSImage *img);
    NSImage * resize(NSImage * img, NSSize size);
    NSImage * fitScreen(NSImage *img);
    NSImage * fitSize(NSImage *img, NSSize size);
    
    NSSize pixelSize(NSImage *img);
    inline NSSize swapSides(NSSize size) {
        NSSize rv;
        rv.width = size.height;
        rv.height = size.width;
        return rv;
    }
    
    class SizeKeeper_t {
    public:
        SizeKeeper_t(NSImage *image) :
            image([image retain]),
            size([image size])
        {}
        
        ~SizeKeeper_t() {
            [image setSize:size];
            [image release];
        }
    private:
        NSImage *image;
        NSSize size;
    };
}
}
