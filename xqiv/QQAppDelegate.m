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
    [super init];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(cmdLine:) name:@"xqiv-cmd" object:nil];
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
      //  [image sizeToFit];

        NSRect frame = [image frame];
        NSImage *img = [[NSImage alloc] initWithContentsOfFile:img_file];
        [img autorelease];
        [image setImage:img];
    
        
    } @catch (...) {}

}

- (IBAction) test:sender {
  
    NSImage *img = [[NSImage alloc] initWithContentsOfFile:@"/tmp/i.jpg"];
    [img autorelease];
    [image setImage: img];
    

    
    /*
    NSSize size;
    size.height = img.size.height / 5;
    size.width = img.size.width / 5;
    [img setSize:size];
    [image setImage:img];
     */
}

@end
