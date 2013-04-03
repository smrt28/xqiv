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
    NSLog(@"acceptsFirstResponder");
    return YES;
}

- (BOOL)becomeFirstResponder {
    NSLog(@"becomeFirstResponder");
    return YES;
}

- (BOOL)resignFirstResponder {
    NSLog(@"resignFirstResponder");
    return YES;
}



- (void)setImage:(NSImage *)image
{
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
    NSLog(@"renderBest!");
}

- (void)mouseEntered:(NSEvent *)theEvent {
    if (_mouseInside) return;
    [[self window] setStyleMask: NSBorderlessWindowMask | NSResizableWindowMask];
    [[self window] setHasShadow:YES];
    _forceBest = YES;
    _mouseInside = YES;
    [self setNeedsDisplay:YES];
    NSLog(@"mouseEntered");
}
- (void)mouseExited:(NSEvent *)theEvent {
    if (!_mouseInside) return;
    [[self window] setStyleMask: NSBorderlessWindowMask];
    [[self window] setHasShadow:NO];
    _forceBest = YES;
    _mouseInside = NO;
    [self setNeedsDisplay:YES];
    NSLog(@"mouseExited");
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
    
    if (_mouseInside || !_image) {
        [[NSColor colorWithSRGBRed:0.5 green:0.5 blue:0.5 alpha:0.5] set];
    } else {
        [[NSColor clearColor] set];
    }
    
    NSRectFill(dirtyRect);
   // NSRectFill([self bounds]);
    if (_image) {
        
        
        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationNone];
        NSImage *toDraw = _image;

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
         
        if (itp || _forceBest) {
            _forceBest = NO;
            NSLog(@"Draw best!");
            NSSize size = isize;
            toDraw = s::img::resize(_image, size);
            [toDraw size];
        } else {
            [self scheduleDrawBest];
        }
        
        [toDraw drawAtPoint:NSMakePoint(0, 0) fromRect:r operation:NSCompositeCopy fraction:1];
        return;
    }
    

}

- (void)keyDown:(NSEvent *)theEvent {
    if ([theEvent keyCode] == kVK_Space) {
        [_delegate nextImage];        
    }
}

@end
