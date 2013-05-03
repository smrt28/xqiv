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
    -(void)prevImage;
    -(void)escape;
    -(void)setAttribute:(NSString *)key value:(NSString *)val;
    -(void)needSizeCheck;
@end


@protocol QQImageViewWndProtocol<NSObject>
-(void)setActive:(BOOL)active;
@end

@interface QQImageView : NSView {
    NSImage *_image;
    NSSize _imageSize;
    NSPoint initialLocation;
    NSTimer *_timer;
    
    NSTimer *_bgTimer;
    CGFloat _bgAlpha;
    
    BOOL _best;
    id<QQImageViewProtocol> _delegate;
    NSTrackingArea * _tracking;
    
    BOOL _bgVisible;
    BOOL _mouseInside;
    BOOL _forceBest;
    int _angle;
    NSSize _originalSize;
}

- (void)rotate:(int)direction;
- (void)setForceBest;
- (void)setImage:(NSImage *)image;
- (void)setDelegate:(id<QQImageViewProtocol>)dlg;
- (void)setAngle:(int)angle;
- (void)setOriginalSize:(NSSize)size;
@end
