//
//  QQImageView.m
//  xqiv
//
//  Created by smrt on 3/17/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQImageView.h"
#import "CImageUtils.h"
#import <Quartz/Quartz.h>
#import <Carbon/Carbon.h>

#import "ns-grcontext.h"
#include "as.h"

namespace {
    int anAngles[4] = {0, -90, 180, 90};
}

@implementation QQImageView

- (void)dealloc {
    [_timer release];
    [_tracking release];
    [super dealloc];
}

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _image = 0;
        _timer = nil;
        _best = NO;
        _delegate = nil;
        _tracking = nil;
        _mouseInside = NO;
        _forceBest = NO;
        _angle = 0;
    }
    
    
    return self;
}

/*
- (BOOL) isOpaque
{
    return YES;
}
*/

- (void)setDelegate:(id<QQImageViewProtocol>)dlg {
    _delegate = dlg;
}

- (void)scheduleDrawBest {
   // return;
    [_timer invalidate];
    _timer = nil;
    if (_best) {
        return;
    }
    _timer = [NSTimer scheduledTimerWithTimeInterval: 0.2
                                              target: self
                                            selector: @selector(renderBest)
                                            userInfo: nil
                                             repeats: NO];
}

- (NSSize)imegeSize {
    NSSize rv = _imageSize;
    if (!_image) {
        rv.height = rv.width = 0;
    }
    return rv;
}

- (BOOL)acceptsFirstResponder {
    return YES;
}

- (BOOL)becomeFirstResponder {
    return YES;
}

- (BOOL)resignFirstResponder {
    return YES;
}



- (void)setImage:(NSImage *)image
{
    _angle = 0;
    if (_image) {
        [_image release];
    }
    [image retain];
    _image = image;
    _imageSize = [_image size];
    
    [self setNeedsDisplay:YES];
}

- (void)mouseDown:(NSEvent *)theEvent {
    
    NSRect  windowFrame = [[self window] frame];
    initialLocation = [NSEvent mouseLocation];
    initialLocation.x -= windowFrame.origin.x;
    initialLocation.y -= windowFrame.origin.y;
}

- (void)mouseDragged:(NSEvent *)theEvent
{
    NSPoint currentLocation;
    NSPoint newOrigin;
    
    NSRect  screenFrame = [[NSScreen mainScreen] frame];
    NSRect  windowFrame = [[self window] frame];
    
    currentLocation = [NSEvent mouseLocation];
    newOrigin.x = currentLocation.x - initialLocation.x;
    newOrigin.y = currentLocation.y - initialLocation.y;
    
    // Don't let window get dragged up under the menu bar
    if( (newOrigin.y+windowFrame.size.height) > (screenFrame.origin.y+screenFrame.size.height) ){
    	newOrigin.y=screenFrame.origin.y + (screenFrame.size.height-windowFrame.size.height);
    }
    
    //go ahead and move the window to the new location
    [[self window] setFrameOrigin:newOrigin];
}

- (void)drawRect:(NSRect)dirtyRect {
    if (_best) {
        [self drawRect:dirtyRect interpolation:1];
        _best = NO;
    } else {
        [self drawRect:dirtyRect interpolation:0];
    }
}

- (void)renderBest {
    _best = YES;
    _timer = nil;
    [self setNeedsDisplay:YES];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    if (_mouseInside) return;
    [[self window] setStyleMask: NSBorderlessWindowMask | NSResizableWindowMask];
    [[self window] setHasShadow:YES];
    _forceBest = YES;
    _mouseInside = YES;
    [self setNeedsDisplay:YES];
}
- (void)mouseExited:(NSEvent *)theEvent {
    if (!_mouseInside) return;
    [[self window] setStyleMask: NSBorderlessWindowMask];
    [[self window] setHasShadow:NO];
    _forceBest = YES;
    _mouseInside = NO;
    [self setNeedsDisplay:YES];
}

- (void)updateTrackingAreas {
    NSRect eyeBox = [self frame];
    if (_tracking) {
        [self removeTrackingArea:_tracking];
        [_tracking release];
        _tracking = nil;
    }
    _tracking = [[NSTrackingArea alloc] initWithRect:eyeBox
                  options: (NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow )
                  owner:self userInfo:nil];
    
    [self addTrackingArea:_tracking];
}

- (void)drawRect:(NSRect)dirtyRect interpolation:(int)itp
{
    int angle = anAngles[_angle % 4];
    
    bool rotated = false;
    if (angle == 90 || angle == -90)
        rotated = true;
    
    
    ns::grcontext_autosave_t grContextSaved;
    
    NSGraphicsContext *context = [NSGraphicsContext currentContext];
    
    NSSize imageSize = _imageSize;
    
    if (rotated) {
        CGFloat tmp;
        tmp =  imageSize.width;
        imageSize.width = imageSize.height;
        imageSize.height = tmp;
    }
    
    if (_mouseInside || !_image) {
        [[NSColor colorWithSRGBRed:0.5 green:0.5 blue:0.5 alpha:0.5] set];
    } else {
        [[NSColor clearColor] set];
    }
    
    NSRectFill(dirtyRect);
    
    //[_rotate concat];

    // NSRectFill([self bounds]);
    if (_image) {
        s::img::SizeKeeper_t sizeKeeper(_image);
        
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
        NSImage *toDraw = _image;

        NSSize isize;
        NSSize vsize;
        CGFloat x, y;
        
        vsize = [self bounds].size;
        isize = vsize;
        

        
        if (imageSize.height > vsize.height || imageSize.width > vsize.width) {
            NSLog(@"need resize");
        } else {
            [_image setSize:imageSize];
            isize = imageSize;
            x = vsize.height - (isize.height + vsize.height) / 2;
            y = vsize.width - (isize.width + vsize.width) / 2;
            NSRect r =
            NSMakeRect(-y, -x, [_image size].width+y, [_image size].height + x);

            [toDraw drawAtPoint:NSMakePoint(0, 0) fromRect:r operation:NSCompositeCopy fraction:1];
            NSLog(@"doesn't need resize");
            return;
        }
        
        CGFloat hw = imageSize.height / imageSize.width;
        
        isize.height = isize.width * hw;       
        
        if (isize.width > vsize.width || isize.height > vsize.height) {
            isize = vsize;
            CGFloat hw = imageSize.width / imageSize.height;
            isize.width = isize.height * hw;
        }
        
        x = vsize.height - (isize.height + vsize.height) / 2;
        y = vsize.width - (isize.width + vsize.width) / 2;
        
        if (rotated) {
            [_image setSize:s::img::swapSides(isize)];
        } else {
            [_image setSize:isize];
        }
        
        NSRect r;
        if (rotated) {
            r = NSMakeRect(-x, -y, [_image size].width + x, [_image size].height + y);
        } else {
            r = NSMakeRect(-y, -x, [_image size].width + y, [_image size].height + x);
        }
        
        NSLog(@"x=%f y=%f, w=%f, h=%f", x, y, [_image size].width, [_image size].height);

        
        if (itp || _forceBest) {
            _forceBest = NO;
            NSSize size;
            if (rotated) {
                size = s::img::swapSides(isize);
            } else {
                size = isize;
            }
            
            
            toDraw = s::img::resize(_image, size);
            [toDraw size];
        } else {
            [self scheduleDrawBest];
        }
        nss::object_t<NSAffineTransform> rotate;
        switch (angle) {
            case -90:
                [rotate translateXBy:0 yBy:vsize.height];
                [rotate rotateByDegrees:-90];
                [rotate concat];
                break;
            case 90:
                [rotate translateXBy:vsize.width yBy:0];
                [rotate rotateByDegrees:90];
                [rotate concat];
                break;
            case 180:
                [rotate translateXBy:vsize.width yBy:vsize.height];
                [rotate rotateByDegrees:-180];
                [rotate concat];
                break;
        }
        [toDraw drawAtPoint:NSMakePoint(0, 0) fromRect:r operation:NSCompositeCopy fraction:1];
        return;
    }
    

}

- (void)rotate {
    _angle++;
   [self setNeedsDisplay:YES];
}

- (void)setForceBest {
    _forceBest = YES;
}

- (void)keyDown:(NSEvent *)theEvent {
    NSLog(@"key:0x%x", [theEvent keyCode]);
    
    switch([theEvent keyCode]) {
        case kVK_Space:
            [_delegate nextImage];
            break;
        case kVK_Delete:
            [_delegate prevImage];
            break;
        case kVK_Escape:
            [_delegate escape];
            break;
        case 0x21:
            [self rotate];
            break;
    }
}

@end
