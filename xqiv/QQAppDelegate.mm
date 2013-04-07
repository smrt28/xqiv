//
//  QQAppDelegate.m
//  xqiv
//
//  Created by smrt on 3/16/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQAppDelegate.h"
#import "SDictionary.h"

@implementation QQAppDelegate

- (void)dealloc
{
    //[_timer release];
    [super dealloc];
}

-(id)init {
    self = [super init];
    _cache.setDelegate(self);
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
            s::Dictionary_t item;
            item.insert("filename", arg);
            _cache.insert(item);
            if (i==1) img_file = arg;
        }

        _cache.go();
        
    } @catch (...) {}
}

- (void)showCachedImage:(NSDictionary *)item {
    NSImage *img = [item objectForKey:@"image"];
    NSNumber *index = [item objectForKey:@"index"];
    NSLog(@"showing: %ld", (long)[index integerValue]);
    NSApplication *myApp = [NSApplication sharedApplication];
    [myApp activateIgnoringOtherApps:YES];
    [_window orderFrontRegardless];
    [_window makeKeyAndOrderFront:_window];
    [_window makeKeyWindow];
    [image setImage:img];
}

-(void)nextImage {
    _cache.next();
}
-(void)prevImage {
    _cache.prev();
}

-(void)awakeFromNib {
    [_window setLevel:NSScreenSaverWindowLevel + 1];
    [_window orderFront:nil];
    [image setDelegate:self];
}

-(void)escape {
    _cache.clear();
    [[NSApplication sharedApplication] hide:self];
//    [_window ]
    
}

@end
