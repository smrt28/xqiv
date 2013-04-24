//
//  imagecache.cpp
//  xqiv
//
//  Created by smrt on 4/21/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "imagecache.h"
#import "ns-dict.h"

#include <set>

@implementation QQCacheItem
-(id)init {
    self = [super init];
    [self setFilename: nil];
    [self setImage: nil];
    [self setErrorcode: 0];
    self.state = s::ics::NOTLOADED;
    return self;
}

- (void)dealloc {
    [self setImage:nil];
    [self setSha1:nil];
    [self setFilename:nil];

    [super dealloc];
}
@end

namespace s {
    void ImageCache_t::loaded(NSMutableDictionary *aDict) {
        ns::dict_t d(aDict);
        
        NSImage *img = d[@"image"].as<NSImage>();
        ns::dict_t udata(d[@"userdata"]);
        if (udata[@"version"].as<int>() != version) {
            run();
            return;
        }
        size_t idx = udata[@"index"].as<int>();
        
        NSLog(@"loaded: %zd", idx);
        
        QQCacheItem * cache = item_at(idx);
        
        if (d[@"errorcode"].as<int>() != 0) {
            cache.image = nil;
            cache.state = ics::INVALID;
            if (lastAction) {
                (this->*lastAction)();
            }
            return;
        }

        
        cache.image = img;
        cache.state = ics::LOADED;
        
        cache.sha1 = d[@"sha1"].as<NSString>();
        if (idx == pivot) {
            [viewCtl showImage:img];
        }
        run();
    }
    
    
    void ImageCache_t::run() {
        for(Loaders_t::iterator it = loaders.begin(),
            eit = loaders.end();
            it != eit; ++it)
        {
            if (it->inProgress()) continue;

            size_t td = todo();
            if (td == NOINDEX) return;
            
            ns::dict_t udata;
            udata.insert(@"index", [NSNumber numberWithLong:td]);
            udata.insert(@"version", [NSNumber numberWithLong:version]);
            NSString *filename = item_at(td).filename;
            item_at(td).state = ics::LOADING;
            it->load(filename, udata.objc());
        }
    }
    
    void ImageCache_t::ready() {
        reset_keep();
        run();
    }
    

    
    bool ImageCache_t::moveTo(size_t idx) {
        if (idx >= size()) return false;
        pivot = idx;
        reset_keep();
        
        return false;
    }
    
    void ImageCache_t::unload(size_t idx) {
        if (item_at(idx).state == ics::LOADING) {
            item_at(idx).state = ics::NOTLOADED;
            return;
        }
        
        if (item_at(idx).state != ics::LOADED) {
            return;
        }
    
        item_at(idx).image = nil;
        item_at(idx).state = ics::NOTLOADED;
    }
    
    void ImageCache_t::reset_keep() {
        for (size_t i = 0; i < size(); i++) {
            item_at(i).keep = false;
        }
        
        int bw = FW, fw = FW;
        item_at(pivot).keep = true;
        
        
        for(size_t idx = next(pivot);idx != pivot;idx = next(idx)) {
            if (item_at(idx).state == ics::INVALID) continue;
            item_at(idx).keep = true;
            fw--;
            if (fw == 0) break;
        }
        
        for(size_t idx = prev(pivot);idx != pivot;idx = prev(idx)) {
            if (item_at(idx).state == ics::INVALID) continue;
            item_at(idx).keep = true;
            bw--;
            if (bw == 0) break;
        }

        for (size_t i = 0; i < size(); i++) {
            if (!item_at(i).keep) {
                unload(i);
            }
        }
    }
    
    
    size_t ImageCache_t::todo() {

        int bw = BW, fw = FW;
        
        if (item_at(pivot).state == ics::NOTLOADED) {
            return pivot;
        }
        
        for(size_t idx = next(pivot);idx != pivot;idx = next(idx)) {
            int state = item_at(idx).state;
            
            if (state == ics::INVALID) continue;
            
            if (state == ics::LOADED || state == ics::LOADING) {
                fw--; if (!fw) break;
            }
            
            if (state == ics::NOTLOADED) {
                return idx;
            }
        }
        
        for(size_t idx = prev(pivot);idx != pivot;idx = prev(idx)) {

            int state = item_at(idx).state;
            
            if (state == ics::INVALID) continue;
            
            if (state == ics::LOADED || state == ics::LOADING) {
                bw--; if (!bw) break;
            }
            
            if (state == ics::NOTLOADED) {
                return idx;
            }
        }
        
        return NOINDEX;
    }
    
    QQCacheItem * ImageCache_t::push_back(NSString *filename) {
        QQCacheItem * item = [[[QQCacheItem alloc] init] autorelease];
        item.filename = filename;
        images.push_back(item);
        return item;
    }
}