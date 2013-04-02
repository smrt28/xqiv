//
//  QQImageView.h
//  xqiv
//
//  Created by smrt on 3/17/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol QQImageViewProtocol<NSObject>
    -(void)nextImage;
@end

@interface QQImageView : NSView {
    NSImage *_image;
    NSSize _imageSize;
    NSPoint initialLocation;
    NSTimer *_timer;
    BOOL _best;
    id<QQImageViewProtocol> _delegate;
}

- (void)setImage:(NSImage *)image;
- (void)setDelegate:(id<QQImageViewProtocol>)dlg;
@end
