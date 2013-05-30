//
//  QQInfoWindowController.h
//  xqiv
//
//  Created by smrt on 5/18/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QQCacheBridge.h"
#import "QQAttributes.h"
#import "as.h"
@interface QQInfoWindowController : NSWindowController {
    IBOutlet NSTextField *_sha1;
    IBOutlet NSTextField *_filename;
    IBOutlet NSTextField *_loaded;
    IBOutlet NSTextField *_loadedFw;
    IBOutlet NSButton    *_star;
    IBOutlet NSImageView *_starImage;

    NSImage *_star64;
    NSImage *_star64rb;

    ns::base_t<QQCacheItem, false> _item;
    ns::base_t<QQCacheInfo, false> _info;
    ns::base_t<QQAttributes, false> _attributes;
}

-(void)setAttributes:(QQAttributes *)attributes;

-(IBAction)starButton:(id)sender;
-(IBAction)copyButton:(id)sender;
-(IBAction)showInFinder:(id)sender;

-(void) update:(QQCacheItem *)item cacheInfo:(QQCacheInfo *)info;
@end
