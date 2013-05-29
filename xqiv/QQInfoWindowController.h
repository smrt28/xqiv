//
//  QQInfoWindowController.h
//  xqiv
//
//  Created by smrt on 5/18/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QQCacheBridge.h"
#import "as.h"
@interface QQInfoWindowController : NSWindowController<NSTableViewDelegate, NSTableViewDataSource> {
    IBOutlet NSTextField *_sha1;
    IBOutlet NSBox *_filename;
    IBOutlet NSTextField *_loaded;
    IBOutlet NSTextField *_loadedFw;
    IBOutlet NSTableView *_labels;
    ns::base_t<QQCacheItem, false> _item;
    ns::base_t<QQCacheInfo, false> _info;
}
-(IBAction)copyButton:(id)sender;
-(IBAction)showInFinder:(id)sender;

-(void) update:(QQCacheItem *)item cacheInfo:(QQCacheInfo *)info;
@end
