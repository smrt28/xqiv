//
//  QQImageView.h
//  xqiv
//
//  Created by smrt on 3/17/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface QQImageView : NSView {
    NSImage *_image;
    NSSize _imageSize;
    NSPoint initialLocation;
}

- (void)setImage:(NSImage *)image;

@end
