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
    
    void setTransformation(int angle, nss::object_t<NSAffineTransform> &rotate,
                           NSSize vsize)
    {
        
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
    }
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
        _bgTimer = nil;
        _best = NO;
        _delegate = nil;
        _tracking = nil;
        _mouseInside = NO;
        _forceBest = NO;
        _bgVisible = NO;
        _angle = 0;
        _bgAlpha = 0.5;
        _calmBorders = NO;
        _blink = NO;
    }

    return self;
}


- (void)setDelegate:(id<QQImageViewProtocol>)dlg {
    _delegate = dlg;
}

- (void)scheduleHideBg {
    _bgVisible = YES;
    [_bgTimer invalidate];
    _bgTimer = nil;
    _bgTimer = [NSTimer scheduledTimerWithTimeInterval: 0.3
                                              target: self
                                            selector: @selector(hideBg)
                                            userInfo: nil
                                             repeats: NO];
}

- (void)hideBg {
    _bgTimer = nil;
    if (!_bgVisible) return;
    _bgVisible = NO;
    _forceBest = YES;
    [self setNeedsDisplay:YES];
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
    if (!image) {
        if (!_image) return;
        [_image release];
        _image = nil;
        [self setNeedsDisplay:YES];
        return;
    }

    _angle = 0;
    if (_image) {
        [_image release];
    }
    [image retain];
    _image = image;
    _imageSize = [_image size];
    _originalSize = [_image size];
    if (_mouseInside) {
        _calmBorders = YES;
        [NSCursor setHiddenUntilMouseMoves:YES];
    }
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
    
    if ((newOrigin.y+windowFrame.size.height) >
        (screenFrame.origin.y+screenFrame.size.height))
    {
    	newOrigin.y = screenFrame.origin.y +
            (screenFrame.size.height-windowFrame.size.height);
    }
    
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
    _forceBest = YES;
    _mouseInside = YES;
    [self setNeedsDisplay:YES];
}
- (void)mouseExited:(NSEvent *)theEvent {
    if (!_mouseInside) return;
    _forceBest = YES;
    _mouseInside = NO;
    [self setNeedsDisplay:YES];
}

- (void)mouseMoved:(NSEvent *)theEvent {
    if (_calmBorders) {
        _calmBorders = NO;
        [self setNeedsDisplay:YES];
    }
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
    NSSize originalSize = _originalSize;

    if (rotated) {
        imageSize = s::img::swapSides(imageSize);
        originalSize = s::img::swapSides(originalSize);
    }

    if (_bgVisible)
        _forceBest = YES;

    if (!_calmBorders && (_mouseInside || _bgVisible)) {
        [[self window] setHasShadow:YES];
        [[NSColor colorWithSRGBRed:0.5 green:0.5 blue:0.5 alpha:_bgAlpha] set];
    } else {
        [[self window] setHasShadow:NO];
        [[NSColor clearColor] set];
    }

    NSRectFill(dirtyRect);

    if (!_image) return;


    s::img::SizeKeeper_t sizeKeeper(_image);

    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
    NSImage *toDraw = _image;

    NSSize isize;
    NSSize vsize;
    CGFloat x, y;

    vsize = [self bounds].size;
    isize = vsize;

    nss::object_t<NSAffineTransform> rotate;
    NSRect r;
    
    if (originalSize.height > vsize.height || originalSize.width > vsize.width) {
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

        
        if (rotated) {
            r = NSMakeRect(-x, -y, [_image size].width + x, [_image size].height + y);
        } else {
            r = NSMakeRect(-y, -x, [_image size].width + y, [_image size].height + x);
        }

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
        setTransformation(angle, rotate, vsize);
    } else
    {
        imageSize = originalSize;
        if (rotated) {
            [_image setSize:s::img::swapSides(imageSize)];
        } else {
            [_image setSize:imageSize];
        }

        nss::object_t<NSAffineTransform> rotate;
        setTransformation(angle, rotate, vsize);

        isize = imageSize;
        x = vsize.height - (isize.height + vsize.height) / 2;
        y = vsize.width - (isize.width + vsize.width) / 2;

        if (rotated) {
            r = NSMakeRect(-x, -y, [_image size].width + x, [_image size].height + y);
        } else {
            r = NSMakeRect(-y, -x, [_image size].width + y, [_image size].height + x);
        }
    }

   // [[NSColor colorWithSRGBRed:1 green:1 blue:1 alpha:1] set];
    //NSRectFill(r);
    [toDraw drawAtPoint:NSMakePoint(0, 0) fromRect:r operation:NSCompositeCopy fraction:1];
}

- (void)rotate:(int)direction {
    _angle += direction;
    if (_angle < 0) _angle = 3;
    _angle %= 4;
    [self scheduleHideBg];
    [self setNeedsDisplay:YES];
}

- (void)setForceBest {
    _forceBest = YES;
}

-(void)setAngle:(int)angle {
    if (angle < 0) return;
    if (angle > 3) return;
    _angle = angle;

    [self setNeedsDisplay:YES];
}

- (void)setOriginalSize:(NSSize)size {
    _originalSize = size;
}

- (void)keyUp:(NSEvent *)theEvent {
    switch([theEvent keyCode]) {
        case 0x45: // +
        case 0x4e: // -
            [_delegate needSizeCheck];
            break;
    }
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
        case 0xc: // q
            [_delegate escape];
            break;
        case 0x21: // [
            [self rotate:-1];
            [_delegate setAttribute:@"angle" value:[NSString stringWithFormat:@"%d", _angle]];
            break;
        case 0x1e: // ]
            [self rotate:+1];
            [_delegate setAttribute:@"angle" value:[NSString stringWithFormat:@"%d", _angle]];
            break;
        case 0x3: { // f
            break;
        }
        case 0x45: { // +
            NSWindow *w = [self window];
            NSRect r = [w frame];
            r.size.width += 10;
            r.size.height += 10;
            r.origin.x -= 5;
            r.origin.y -= 5;
            [w setFrame:r display:YES];
            [self scheduleHideBg];
            break;
        }
        case 0x4e: {
            NSWindow *w = [self window];
            NSRect r = [w frame];
            if (r.size.width > 50 && r.size.height > 50) {
                r.size.width -= 10;
                r.size.height -= 10;
                r.origin.x += 5;
                r.origin.y += 5;
                [w setFrame:r display:YES];
                [self scheduleHideBg];
            }
            break;
        }
    }
}

@end
