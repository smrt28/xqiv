//
//  imagecache.h
//  xqiv
//
//  Created by smrt on 4/21/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQImageLoader.h"
#import "QQImageView.h"
#import "ns-array.h"

#include <vector>
#include <set>
#include <list>

namespace s {
    namespace ics {
        static const int INVALID = -1;
        static const int LOADED = 1;
        static const int LOADING = 2;
        static const int NOTLOADED = 3;
    }
}

@interface QQCacheItem : NSObject
@property (readwrite,retain) NSImage *image;
@property (readwrite,retain) NSString *filename;
@property (readwrite,retain) NSString *sha1;
@property (readwrite) int errorcode;
@property (readwrite) int state;
@property (readwrite) bool keep;
@end

namespace  s  {
    
    class ImageCache_t : public ImgLoaderListener_t {
        static const size_t NOINDEX = ~(size_t(0));
        
    public:
        
        
        virtual ~ImageCache_t() {}
        ImageCache_t() :
            viewCtl(nil),
            pivot(0),
            resources(13), BW(3), FW(8),
            version(1),
            lastAction(&ImageCache_t::show_next)
        {
            loaders.push_back(ImageLoader_t(this));
            loaders.push_back(ImageLoader_t(this));
            loaders.push_back(ImageLoader_t(this));
            loaders.push_back(ImageLoader_t(this));

        }
        
        void loaded(NSMutableDictionary *);
        void setCtl(id<QQImageCtl> vctl) {
            [vctl retain];
            [viewCtl release];
            viewCtl = vctl;
        }
        
        bool moveTo(size_t idx);
        
        QQCacheItem * push_back(NSString *filename);
        
        void clear() {
            images.clear();
        }
        
        size_t size() { return images.size(); }
        
        void set_keep(size_t idx, bool b);
        
        QQCacheItem * item_at(size_t idx) {
            if (idx >= size()) return nil;
            return images[idx].as<QQCacheItem>();
        }
        
        size_t goNext(size_t pvt) {
            size_t idx;
            for (idx = next(pvt); idx!=pvt; idx = next(idx)) {
                if (item_at(idx).state != ics::INVALID) break;
            }
            return idx;
        }

        size_t goPrev(size_t pvt) {
            size_t idx;
            for (idx = prev(pvt); idx!=pvt; idx = prev(idx)) {
                if (item_at(idx).state != ics::INVALID) break;
            }
            return idx;
        }

        template<size_t (ImageCache_t::*xnext)(size_t)>
        void show() {
            if (item_at(pivot).state == ics::NOTLOADED) {
                NSLog(@"skip next, image is loading!");
                return;
            }
            
            pivot = (this->*xnext)(pivot);
            
            if (item_at(pivot).state == ics::INVALID) {
                NSLog(@"no valid image");
                return;
            }
            
            if (item_at(pivot).state == ics::LOADED) {
                [viewCtl showImage:item_at(pivot).image];
            }
            
            lastAction = &ImageCache_t::show<xnext>;
            reset_keep();
            run();
            
        }
        
        void show_next() {
            show<&ImageCache_t::goNext>();
        }
        
        void show_prev() {
            show<&ImageCache_t::goPrev>();
        }

        void ready();
        
        size_t get_position() {
            return pivot;
        }
        
    private:
        void unload(size_t idx);
        void load(size_t idx);
        void run();
        
        size_t next(size_t idx) {
            idx++;
            if (idx >= size()) return 0;
            return idx;
        }
        
        size_t prev(size_t idx) {
            if (idx == 0) {
                return size() - 1;
            }
            return idx - 1;
        }
        
        void reset_keep();
        
        size_t todo();
    private:
        typedef std::vector<s::ImageLoader_t> Loaders_t;
        Loaders_t loaders;
        id<QQImageCtl> viewCtl;
        ns::array_t images;
        size_t pivot;
        size_t resources;
        int BW, FW;
        int version;
        void (ImageCache_t::*lastAction)();
    };
}

