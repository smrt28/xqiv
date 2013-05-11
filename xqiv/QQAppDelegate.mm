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
    _cache.loadAttributes();
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
        
        [self needSizeCheck];
        
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
    [image setDelegate:self];
}

-(void)escape {
    _cache.clear();
    [image setImage:nil];
    [[NSApplication sharedApplication] hide:self];
    _cache.saveAttributes();
}
- (void)showImage:(NSImage *)img attributes:(NSMutableDictionary *)attrs
         origSize:(NSSize)osize
{
    if (!img) {
        [self escape];
        return;
    }

    [image setForceBest];
    [image setImage:img];
    [image setOriginalSize:osize];

    if (attrs) {
        ns::dict_t d(attrs);
        int angle = d[@"angle"].as<int>();
        [image setAngle: angle];
    }
}

-(void)setAttribute:(NSString *)key value:(NSString *)val {
    _cache.set_attribute(key, val);
}

-(void)needSizeCheck {
    NSRect frame = [_window frame];
    _cache.set_new_size(frame.size);
}

- (void)windowDidEndLiveResize:(NSNotification *)notification {
    NSRect frame = [_window frame];
    _cache.set_new_size(frame.size);
    NSLog(@"resized %f", frame.size.width);
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    _cache.saveAttributes();
}
@end
