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
#import "ns-dict.h"

#include <vector>
#include <set>
#include <list>

#import "QQStruct.h"
#import "ns-array-of.h"

namespace s {
    namespace ics {
        static const int INVALID = -1;
        static const int LOADED = 1;
        static const int LOADING = 2;
        static const int NOTLOADED = 3;
        static const int NEEDRELOAD = 4;
    }
    namespace aux {
    inline bool need_reload(int state) {
        if (state == s::ics::NOTLOADED || state == s::ics::NEEDRELOAD)
            return true;
        return false;
    }
    }
}

@interface QQCacheItem : NSObject
@property (readwrite,retain) NSImage *image;
@property (readwrite,retain) NSString *filename;
@property (readwrite,retain) NSString *sha1;
@property (readwrite) NSSize originalsize;
@property (readwrite) int errorcode;
@property (readwrite) int state;
@property (readwrite) bool keep;
@end

namespace  s  {
    


    class ImageCache_t : public ImgLoaderListener_t {
        static const size_t NOINDEX = ~(size_t(0));
        
    public:
        enum Direction_t {
            NEXT = 1,
            PREV = ~NEXT
        };

        virtual ~ImageCache_t() {
            
        }

        ImageCache_t() :
            viewCtl(nil),
            pivot(0),
            BW(104857600), FW(419430400),
            version(1),
            lastAction(&ImageCache_t::show_next),
            cachedImageSize([[NSScreen mainScreen] visibleFrame].size),
            swapCnt(5)
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
            return images[idx];
        }

        template<size_t (ImageCache_t::*xnext)(size_t)>
        void show() {
            if (pivot >= size()) pivot = 0;
            if (item_at(pivot).state == ics::NOTLOADED) {
                NSLog(@"skip next, image is loading!");
                return;
            }
            
            pivot = (this->*xnext)(pivot);
            
            if (item_at(pivot).state == ics::INVALID) {
                [viewCtl showImage:nil
                        attributes:nil
                          origSize:NSSize()];

                NSLog(@"no valid image");
                return;
            }
            
            if (item_at(pivot).state == ics::LOADED) {
                [viewCtl showImage:item_at(pivot).image
                        attributes:attr(false).objc()
                 origSize:item_at(pivot).originalsize];
            }
            
            lastAction = &ImageCache_t::show<xnext>;
            reset_keep();
            run();
            
        }

        template<Direction_t direction>
        size_t goToImage(size_t pvt) {
            size_t idx;
            if (pvt >= size()) return 0;
            for (idx = go<direction>(pvt); idx!=pvt; idx = go<direction>(idx)) {
                if (item_at(idx).state != ics::INVALID) break;
            }
            return idx;
        }

        void show_next() {
            if (FW < BW) {
                if (swapCnt == 0) {
                    std::swap(BW,FW);
                } else {
                    swapCnt--;
                }
            } else {
                swapCnt = 5;
            }
            show<&ImageCache_t::goToImage<NEXT> >();
        }
        
        void show_prev() {
            if (FW > BW) {
                if (swapCnt == 0) {
                    std::swap(BW,FW);
                } else {
                    swapCnt --;
                }
            } else {
                swapCnt = 5;
            }
            show<&ImageCache_t::goToImage<PREV> >();
        }

        void ready();
        
        size_t get_position() {
            return pivot;
        }
        
        void ensure_not_buzy();
        
        NSString * get_attribute(NSString *key);
        void set_attribute(NSString *key, NSString *value);
        
        
        void set_new_size(NSSize size);

        void saveAttributes();
        void loadAttributes();

    private:
        void unload(size_t idx);
        void load(size_t idx);
        void run();

        void update_view();
        
        ns::dict_t attr(bool create = true);
        bool hasAttr();


        template<Direction_t direction>
        size_t go(size_t idx) {
            switch(direction) {
                case NEXT:
                    idx++;
                    if (idx >= size()) return 0;
                    return idx;

                case PREV:
                    if (size() == 0) return 0;
                    if (idx == 0) {
                        return size() - 1;
                    }
                    return idx - 1;
            }
        }

        template<Direction_t direction>
        size_t go_rev(size_t idx) {
            return go<~direction>(idx);
        }


        template<Direction_t direction>
        size_t todo_() {
            size_t mem = 4 * cachedImageSize.width * cachedImageSize.height;
            size_t bw;
            if (direction == NEXT) {
                bw = FW;
            } else {
                bw = BW;
            }
            for(size_t idx = go<direction>(pivot);idx != pivot;idx = go<direction>(idx)) {
                int state = item_at(idx).state;

                if (state == ics::INVALID) continue;

                if (state == ics::LOADED || state == ics::LOADING) {
                    if (bw < mem) break;
                    bw -= mem;
                }

                if (aux::need_reload(state)) {
                    return idx;
                }
            }
            return NOINDEX;
        }


        void reset_keep();
        
        size_t todo();

    private:
        typedef std::vector<s::ImageLoader_t> Loaders_t;
        Loaders_t loaders;
        id<QQImageCtl> viewCtl;
        ns::array_of_t<QQCacheItem> images;
        ns::dict_t attributes;
        size_t pivot;
        size_t BW, FW;
        int version;
        void (ImageCache_t::*lastAction)();
        NSSize cachedImageSize;
        int swapCnt;
    };
}

