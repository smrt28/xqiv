//
//  QQAppDelegate.h
//  xqiv
//
//  Created by smrt on 3/16/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QQImageView.h"
#import "QQImageLoader.h"
#import "QQAttributes.h"
#import "imagecache.h"
#import "QQInfoWindowController.h"
#import "as.h"

@interface QQAppDelegate : NSObject <NSApplicationDelegate,
    QQImageViewProtocol, QQImageCtl, NSWindowDelegate>
{
    IBOutlet QQImageView * image;
    IBOutlet NSWindow *_window;

    QQInfoWindowController *_infoCtl;

    s::ImageCache_t _cache;

    ns::base_t<QQCacheItem, false> _currentItem;

    QQAttributes *_attributes;
}

-(BOOL)nextImage;
-(BOOL)prevImage;
-(void)escape;
- (void)showImage:(NSImage *)img  origSize:(NSSize)size;



@end
