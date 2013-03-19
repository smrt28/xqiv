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
    [_imageLoader dealloc];
    [super dealloc];
}

-(id)init {
    [super init];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(cmdLine:) name:@"xqiv-cmd" object:nil];
    _imageLoader = [QQImageLoader loader:@selector(imageLoaded:) target:self];
    
    [_imageLoader start];
    return self;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
}


- (void)cmdLine:(NSNotification *)note {

    @try {
        NSString *img_file = 0;
        NSDictionary *userInfo = [note userInfo];
        int argc = [[userInfo objectForKey:@"argc"] intValue];
        NSDictionary *argInfo = [userInfo objectForKey:@"args"];
        for (int i=0; i<argc; i++) {
            NSString *arg = [argInfo objectForKey:[NSString stringWithFormat:@"%d", i]];
            if (i==1) img_file = arg;
        }
        
        if (!img_file) return;

        NSRect frame = [image frame];
        NSImage *img = [[NSImage alloc] initWithContentsOfFile:img_file];
        [img autorelease];
        [image setImage:img];
    
        
    } @catch (...) {}

}

- (void)imageLoaded:(NSMutableDictionary *)obj {
    NSImage *img = [obj objectForKey:@"image"];
    NSString *filename = [obj objectForKey:@"filename"];
    [image setImage:img];
}

- (IBAction) test:sender {
    NSString *filename = [[[NSString alloc] initWithFormat:@"/tmp/i.jpg"] autorelease];
    [_imageLoader insertImageTask:filename];
}


-(void)awakeFromNib {
    [_window setLevel:NSScreenSaverWindowLevel + 1];
    [_window orderFront:nil];
}

@end
