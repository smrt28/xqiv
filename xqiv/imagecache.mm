//
//  imagecache.cpp
//  xqiv
//
//  Created by smrt on 4/21/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "imagecache.h"
#import "ns-dict.h"
@implementation QQCacheItem
-(id)init {
    self = [super init];
    [self setFilename: nil];
    [self setImage: nil];
    [self setErrorcode: 0];
    return self;
}
@end

namespace s {
    void ImageCache_t::loaded(NSMutableDictionary *aDict) {
        ns::dict_t d(aDict);
        NSImage *img = d[@"image"].as<NSImage>();
        NSImage *ssss = img;
        [viewCtl showImage:img];
        
        
        QQCacheItem * cache = [[[QQCacheItem alloc] init] autorelease];
        cache.image = img;
        
    }
    
    void ImageCache_t::load(NSString *filename, id userData) {
        for(Loaders_t::iterator it = loaders.begin(), eit = loaders.end();
            it != eit; ++it)
        {
            if (loaders[0].load(filename, userData))
                return;
        }
    }
    
    QQCacheItem * ImageCache_t::push_back(NSString *filename) {
        nextItemId++;
        QQCacheItem * item = [[[QQCacheItem alloc] init] autorelease];
        item.filename = filename;
        item.itemId = nextItemId;
        images.push_back(item);
        return item;
    }
}