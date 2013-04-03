//
//  QQQivWindow.m
//  xqiv
//
//  Created by smrt on 4/3/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQQivWindow.h"

@implementation QQQivWindow


- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)aStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)flag {
 
    self = [super initWithContentRect:contentRect
                            styleMask:NSBorderlessWindowMask  /*| NSResizableWindowMask */ backing:NSBackingStoreBuffered defer:NO];
    
    if (self != nil) {
        [self setAlphaValue:1];
        [self setOpaque:NO];
        [self setHasShadow:NO];
    }
     
    return self;
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}
/*
- (NSSize)windowWillResize:(NSWindow *)window toSize:(NSSize)proposedFrameSize {
    NSSize imgSize = [_view imegeSize];
    if (!imgSize.width || !imgSize.height) {
        return proposedFrameSize;
    }
    double d = imgSize.height / imgSize.width;

    proposedFrameSize.height = (proposedFrameSize.width * imgSize.height) /imgSize.width ;
    NSLog(@"w/h = %f", d);

    return proposedFrameSize;
}
*/
@end
