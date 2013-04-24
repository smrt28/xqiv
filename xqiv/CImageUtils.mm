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
    
    size_t msize(NSImage *img) {
        /*
        NSArray * repArray = [img representations];
        NSBitmapImageRep *rep = [repArray objectAtIndex:0];
        NSSize originalSize;
        
        size_t h = [rep pixelsHigh];
        size_t w = [rep pixelsWide];
        
        size_t bpp = [rep bitsPerPixel];
        size_t rv = w * h;

        

        return rv;
         */
        return 0;
    }

#if 0

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

    
#else
    NSImage * resize(NSImage * img, NSSize size) {
        NSSize originalSize = [img size];
        NSRect fromRect = NSMakeRect(0, 0, originalSize.width, originalSize.height);
        
        NSImage *rv = [[[NSImage alloc] init] autorelease];

        NSScreen *screen = [NSScreen mainScreen];
        NSDictionary *d = [screen deviceDescription];
        
        NSNumber *bps = [d objectForKey:NSDeviceBitsPerSample];
        NSString * colorSpace = [d objectForKey:NSDeviceColorSpaceName];

        
        NSBitmapImageRep *offscreenRep =
        [[NSBitmapImageRep alloc] initWithBitmapDataPlanes:nil
                                                pixelsWide:size.width
                                                pixelsHigh:size.height
                                             bitsPerSample:[bps intValue]
                                           samplesPerPixel:4
                                                  hasAlpha:YES
                                                  isPlanar:NO
                                            colorSpaceName:colorSpace
                                              bitmapFormat:0
                                               bytesPerRow:nil
                                              bitsPerPixel:32];
        
        
        [offscreenRep autorelease];
        
        NSGraphicsContext* theContext = [NSGraphicsContext
                            graphicsContextWithBitmapImageRep: offscreenRep];
        
        [NSGraphicsContext saveGraphicsState];
        [NSGraphicsContext setCurrentContext: theContext];

        [theContext setImageInterpolation:NSImageInterpolationHigh];
        
        [img drawInRect:NSMakeRect(0, 0, size.width, size.height)
               fromRect:fromRect operation:NSCompositeCopy fraction:1.0f];
        
        [NSGraphicsContext restoreGraphicsState];
        
        
        [rv addRepresentation:offscreenRep];
        [rv setCacheMode:NSImageCacheNever];
        return rv;
    }
    
    
#endif
    
    NSImage *fitSize(NSImage *img, NSSize size) {
        if (!img) {
            return nil;
        }
        NSArray * repArray = [img representations];
        NSImageRep * rep = [repArray objectAtIndex:0];
        
        NSSize originalSize;
        originalSize.height = [rep pixelsHigh ];
        originalSize.width = [rep pixelsWide];
        
        NSSize rv = originalSize;
        NSSize screenFrame = size;
        
        bool needResize = false;
        
        if (rv.width > screenFrame.width) {
            rv.height = (screenFrame.width * rv.height) / rv.width;
            rv.width = screenFrame.width;
        }
        
        if (rv.height > screenFrame.height) {
            rv.width = (screenFrame.height * rv.width) / rv.height;
            rv.height = screenFrame.height;
        }
        
        return resize(img, rv);
    }

    NSImage * fitScreen(NSImage *img) {
        NSSize screenFrame = [[NSScreen mainScreen] visibleFrame].size;
        return fitSize(img, screenFrame);
    }
}
}