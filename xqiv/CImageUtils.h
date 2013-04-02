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
}
}
