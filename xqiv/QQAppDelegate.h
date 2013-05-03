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
#import "imagecache.h"

@interface QQAppDelegate : NSObject <NSApplicationDelegate,
    QQImageViewProtocol, QQImageCtl, NSWindowDelegate>
{
    IBOutlet QQImageView * image;
    IBOutlet NSPanel *_tags;
    IBOutlet NSWindow *_window;
    s::ImageCache_t _cache;
}

-(void)nextImage;
-(void)prevImage;
-(void)escape;
- (void)showImage:(NSImage *)img attributes:(NSDictionary *)attrs origSize:(NSSize)size;


//-(IBAction)test: sender;

//@property (assign) IBOutlet NSWindow *window;

@end
