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
#import "SDictionary.h"
#import "QQCache.h"

@interface QQAppDelegate : NSObject <NSApplicationDelegate, QQImageLoaderProtocol> {
    IBOutlet QQImageView * image;
    IBOutlet NSPanel *_tags;
    QQImageLoader *_imageLoader;
    s::Cache_t _cache;
    int _prefered;
}

- (void)imageLoaded:(NSMutableDictionary *)obj;
- (IBAction) test:sender;
- (IBAction) next:sender;

@property (assign) IBOutlet NSWindow *window;

@end
