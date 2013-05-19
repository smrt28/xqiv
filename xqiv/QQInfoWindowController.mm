//
//  QQInfoWindowController.m
//  xqiv
//
//  Created by smrt on 5/18/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQInfoWindowController.h"

@interface QQInfoWindowController ()

@end

@implementation QQInfoWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

-(void) update:(QQCacheItem *)item {
    [_sha1 setStringValue:item.sha1];
    [_filename setStringValue:item.filename];
}

@end
