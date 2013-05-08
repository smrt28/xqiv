//
//  CImageUtils.m
//  xqiv
//
//  Created by smrt on 3/25/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "CImageUtils.h"

namespace s {
namespace img {

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
    
    NSSize pixelSize(NSImage *img) {
        NSSize originalSize;
        NSArray * repArray = [img representations];
        NSImageRep * rep = [repArray objectAtIndex:0];
        originalSize.height = [rep pixelsHigh];
        originalSize.width = [rep pixelsWide];
        return originalSize;
    }
    
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