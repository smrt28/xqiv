//
//  QQImageView.m
//  xqiv
//
//  Created by smrt on 3/17/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQImageView.h"

@implementation QQImageView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _image = 0;
    }
    
    return self;
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

- (void)drawRect:(NSRect)dirtyRect
{
    if (_image) {
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
        
        return;
    }
    
  //  [[NSColor clearColor] set];
    [[NSColor redColor] set];
    NSRectFill([self bounds]);
     
   

//    NSRectFill([self frame]);
    return;
}

@end
