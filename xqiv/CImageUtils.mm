//
//  CImageUtils.m
//  xqiv
//
//  Created by smrt on 3/25/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "CImageUtils.h"

/*
 NSSize isize;
 NSSize vsize;
 CGFloat x, y;
 
 vsize = [self bounds].size;
 isize = vsize;
 CGFloat hw = _imageSize.height / _imageSize.width;
 isize.height = isize.width * hw;
 
 x = y = 0;
 
 
 if (isize.width > vsize.width || isize.height > vsize.height) {
 x = y = 0;
 isize = vsize;
 CGFloat hw = _imageSize.width / _imageSize.height;
 isize.width = isize.height * hw;
 }
 x = vsize.height - (isize.height + vsize.height) / 2;
 y = vsize.width - (isize.width + vsize.width) / 2;
 
 
 [_image setSize:isize];
 NSRect r =
 NSMakeRect(-y, -x, [_image size].width+y, [_image size].height + x);
 
 [_image drawAtPoint:NSMakePoint(0, 0) fromRect:r operation:NSCompositeCopy fraction:1];
 
 */

namespace s {
namespace img {
    NSImage * resize(NSImage * img, NSSize size) {
        NSImage *rv = [[[NSImage alloc]initWithSize:size] autorelease];
        NSSize originalSize = [img size];
        NSRect fromRect = NSMakeRect(0, 0, originalSize.width, originalSize.height);
        [rv lockFocus];
        [img drawInRect:NSMakeRect(0, 0, size.width, size.height)
               fromRect:fromRect operation:NSCompositeCopy fraction:1.0f];
        [rv unlockFocus];
        return rv;
    }
    
    NSImage *fitSize(NSImage *img, NSSize size) {
        NSArray * repArray = [img representations];
        NSImageRep * rep = [repArray objectAtIndex:0];
        
        NSSize originalSize;
        originalSize.height = [rep pixelsHigh ];
        originalSize.width = [rep pixelsWide];
        
        NSSize rv = originalSize;
        NSSize screenFrame = size;
        
        bool needResize = false;
        
        if (rv.width > screenFrame.width) {
            needResize = true;
            rv.height = (screenFrame.width * rv.height) / rv.width;
            rv.width = screenFrame.width;
        }
        
        if (rv.height > screenFrame.height) {
            needResize = true;
            rv.width = (screenFrame.height * rv.width) / rv.height;
            rv.height = screenFrame.height;
        }

        
        if (!needResize) return img;
        
        return resize(img, rv);
    }

    NSImage * fitScreen(NSImage *img) {
        NSSize screenFrame = [[NSScreen mainScreen] visibleFrame].size;
        return fitSize(img, screenFrame);
    }
}
}