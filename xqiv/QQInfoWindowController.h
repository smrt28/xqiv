//
//  QQInfoWindowController.h
//  xqiv
//
//  Created by smrt on 5/18/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QQCacheBridge.h"

@interface QQInfoWindowController : NSWindowController {
IBOutlet NSTextField *_sha1;
IBOutlet NSTextField *_filename;
}

-(void) update:(QQCacheItem *)item;
@end
