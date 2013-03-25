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
    [_imageLoader dealloc];
    [super dealloc];
}

-(id)init {
    self = [super init];
    
    _imageLoader = [QQImageLoader loader:@selector(imageLoaded:) target:self];
    [[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(cmdLine:) name:@"xqiv-cmd" object:nil];
    [_imageLoader start];
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

        [_imageLoader loadImage:_cache.get()];
        
    } @catch (...) {}

}

- (void)imageLoaded:(NSMutableDictionary *)obj {
    s::Dictionary_t item(obj);
    _cache.update(obj);

    
    NSImage * toShow = _cache[@"image"];
    if (!toShow) return;
    
    //_cache.insert(item["filename"], item);
    [image setImage:toShow];
}


- (IBAction) test:sender {
}

- (IBAction) next:sender {
    if (_cache.size() == 0) return;
    _cache.next();
    
    NSImage * img = _cache[@"image"];
    if (!img) {
        [_imageLoader loadImage:_cache.get()];
        return;
    }
    [image setImage:img];
        
}

-(void)awakeFromNib {
    [_window setLevel:NSScreenSaverWindowLevel + 1];
    [_window orderFront:nil];
}

@end
