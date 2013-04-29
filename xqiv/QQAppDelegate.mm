//
//  QQAppDelegate.m
//  xqiv
//
//  Created by smrt on 3/16/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQAppDelegate.h"

@implementation QQAppDelegate

- (void)dealloc
{
    [super dealloc];
}

-(id)init {
    self = [super init];
    _cache.setCtl(self);
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(cmdLine:) name:@"xqiv-cmd" object:nil];

    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{

}

- (void)cmdLine:(NSNotification *)note {

    @try {
        [[NSApplication sharedApplication] unhide:self];
        _cache.clear();
        NSString *img_file = 0;
        NSDictionary *userInfo = [note userInfo];
        int argc = [[userInfo objectForKey:@"argc"] intValue];
        NSDictionary *argInfo = [userInfo objectForKey:@"args"];
        for (int i=1; i<argc; i++) {
            NSString *arg = [argInfo objectForKey:[NSString stringWithFormat:@"%d", i]];
            _cache.push_back(arg);
            if (i==1) img_file = arg;
        }
        NSApplication *myApp = [NSApplication sharedApplication];
        [myApp activateIgnoringOtherApps:YES];
        [_window orderFrontRegardless];
        [_window makeKeyAndOrderFront:_window];
        [_window makeKeyWindow];
        
        _cache.ready();
        
    } @catch (...) {}
}



-(void)nextImage {
    _cache.show_next();
}
-(void)prevImage {
    _cache.show_prev();
}

-(void)awakeFromNib {
    [_window setLevel:NSScreenSaverWindowLevel + 1];
    [_window orderFront:nil];
    [image setDelegate:self];
}

-(void)escape {
    _cache.clear();
    [[NSApplication sharedApplication] hide:self];
}
- (void)showImage:(NSImage *)img {
    [image setForceBest];
    [image setImage:img];
}

@end
