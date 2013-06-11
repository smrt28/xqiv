//
//  QQAppDelegate.m
//  xqiv
//
//  Created by smrt on 3/16/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//
#import <Carbon/Carbon.h>
#import "QQAppDelegate.h"

@implementation QQAppDelegate

- (void)dealloc
{
    [_attributes release];
    [super dealloc];
}

-(id)init {
    self = [super init];
    _cache.setCtl(self);
    _attributes = _cache.get_attributes();
    [_attributes retain];
    [_attributes load];

    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(cmdLine:) name:@"xqiv-cmd" object:nil];

    _infoCtl = [[QQInfoWindowController alloc] initWithWindowNibName:@"QQInfoWindowController"];
    [_infoCtl setAttributes:_attributes];
    [[_infoCtl window] close];

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
        int i;
        for (i=1; i<argc; i++) {
            NSString *arg = [argInfo objectForKey:[NSString stringWithFormat:@"%d", i]];
            _cache.push_back(arg);
            if (i==1) img_file = arg;
        }
        if (i == 1) return;
        NSApplication *myApp = [NSApplication sharedApplication];
        [myApp activateIgnoringOtherApps:YES];
        [_window orderFrontRegardless];
        [_window makeKeyAndOrderFront:_window];
        [_window makeKeyWindow];
                
        _cache.ready();
        
        [self needSizeCheck];
        
    } @catch (...) {}
}



-(BOOL)nextImage {
    return _cache.show_next();
}
-(BOOL)prevImage {
    return _cache.show_prev();
}

-(void)awakeFromNib {
    [_window setLevel:NSScreenSaverWindowLevel + 1];
    [image setDelegate:self];
}

-(void)escape {
    _cache.clear();
    _currentItem.reset();
    [_infoCtl close];
    [image setImage:nil];
    [[NSApplication sharedApplication] hide:self];
    [_attributes save];
}
- (void)showImage:(QQCacheItem *)item
         origSize:(NSSize)osize
{
    if (!item) {
        [self escape];
        return;
    }

    NSImage *img = item.image;

    [image setForceBest];
    [image setImage:img];
    [image setOriginalSize:osize];

    [_attributes select: item];
    int angle = [_attributes getIntValueForKey:@"angle"];
    [image setAngle: angle];


    _currentItem.reset(item);
    [_infoCtl update:item cacheInfo:nil];
}

- (void)cacheStateChanged:(QQCacheInfo *)cacheInfo {
    [_infoCtl update:nil cacheInfo:cacheInfo];
}

-(void)setAttribute:(NSString *)key value:(NSString *)val {
    [_attributes setValue:val forKey:key];
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
    [_attributes save];
}


- (void)keyDown:(NSEvent *)theEvent {
    switch([theEvent keyCode]) {
        case 0x22: { // i
            NSWindow *w = [_infoCtl window];
            if ([w isVisible]) {
                [w close];
            } else {
                [w orderFront:self];
                [_infoCtl update:_currentItem cacheInfo:nil];
            }
            break;
        }
        case 0x7: // x
            [_attributes select:_currentItem];
            if ([_attributes getIntValueForKey:@"star"]) {
                [_attributes setValue:@"0" forKey:@"star"];
            } else {
                [_attributes setValue:@"1" forKey:@"star"];
            }
            [_infoCtl update:nil cacheInfo:nil];
            break;
        case kVK_Escape:
        case 0xc: // q
            [self escape];
            break;
        case 0x3: // f
            if (!_currentItem) break;
            [[NSWorkspace sharedWorkspace]
             selectFile:[_currentItem.objc() filename] inFileViewerRootedAtPath:nil];
            break;
    }
}

@end
