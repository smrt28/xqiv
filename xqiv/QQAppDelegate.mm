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


- (IBAction) test:sender {
}

- (void)showCachedImage:(NSDictionary *)item {
    NSImage *img = [item objectForKey:@"image"];
    [image setImage:img];
}

- (IBAction) next:sender {
    _cache.next();
}

-(void)awakeFromNib {
    [_window setLevel:NSScreenSaverWindowLevel + 1];
    [_window orderFront:nil];
}

@end
