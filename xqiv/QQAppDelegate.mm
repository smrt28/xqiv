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
    _prefered = -1;
    _imageLoader = [[QQImageLoader alloc] init];
    [_imageLoader setDelegate:self];
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
    NSLog(@"updating image %zd", s::get_item_index(obj));
    _cache.update(obj);
    
    NSImage * toShow = _cache[@"image"];
    if (!toShow) return;

    if (s::get_item_index(obj) == _cache.pos()) {
        [image setImage:toShow];
    }
    
    NSMutableDictionary *todo = _cache.get_todo();
    if (!todo) return;
    [_imageLoader loadImage:todo];
}


- (IBAction) test:sender {
}

- (IBAction) next:sender {
    if (_cache.size() == 0) {
        NSLog(@"empty cache");
        return;
    }
    _cache.next();
    NSLog(@"will show img n=%zd", _cache.pos());
    
    NSImage * img = _cache[@"image"];
    if (!img) {
        NSLog(@"loading image %zd", _cache.pos());
        [_imageLoader incTime];
        [_imageLoader loadImage:_cache.get()];
        return;
    }

    NSLog(@"showing image %zd", _cache.pos());
    [image setImage:img];
}

-(void)awakeFromNib {
    [_window setLevel:NSScreenSaverWindowLevel + 1];
    [_window orderFront:nil];
}

@end
