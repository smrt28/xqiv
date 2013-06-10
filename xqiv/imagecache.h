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
#import "CTime.h"
#import "QQCacheBridge.h"
#import "QQAttributes.h"

namespace  s  {
    


    class ImageCache_t : public ImgLoaderListener_t {
        static const size_t NOINDEX = ~(size_t(0));

    public:

        class images_t : public ns::array_of_t<QQCacheItem> {
        public:

            QQCacheItem * at(size_t idx) {
                if (size() == 0) return nil;
                return ns::array_of_t<QQCacheItem>::operator[](idx % size());
            }

            QQCacheItem * operator [](size_t idx) {
                return at(idx);
            }

            void for_each(void (images_t::*fn)(size_t)) {
                for (size_t i = 0; i < size(); i++) {
                    (this->*fn)(i);
                }
            }


            void unload(size_t idx) {
                if (!at(idx)) return;
                if (at(idx).state == ics::LOADING ||
                    at(idx).state == ics::NEEDRELOAD)
                {
                    at(idx).state = ics::NOTLOADED;
                    return;
                }

                if (at(idx).state != ics::LOADED) {
                    return;
                }
                at(idx).image = nil;
                at(idx).state = ics::NOTLOADED;
            }

            void reload(size_t idx) {
                if (at(idx).state == s::ics::LOADED) {
                    at(idx).state = s::ics::NEEDRELOAD;
                }
            }

            void reload() {
                for_each(&images_t::reload);
            }

            void unload() {
                for_each(&images_t::unload);
            }

            size_t find_sha1(NSString *sha1) {
                for (size_t i = 0; i < size(); i++) {
                    if (!at(i).sha1) continue;
                    if ([at(i).sha1 isEqualToString:sha1]) {
                        return i;
                    }
                }
                return size();
            }

            void load_duplicates(void) {
                for (size_t i = 0; i < size(); i++) {
                    if (at(i).duplicate && at(i).state == s::ics::INVALID) {
                        at(i).state = s::ics::NOTLOADED;
                    }
                }
            }

            void clear_duplicates(void) {
                for (size_t i = 0; i < size(); i++) {
                    if (at(i).duplicate) {
                        at(i).state = s::ics::INVALID;
                        at(i).image = nil;
                    }
                }
            }
        };



        static const int SWITCH_TO_SWAP_FW_BW = 5;
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
            cachedImageSize([[NSScreen mainScreen] visibleFrame].size),
            swapCnt(SWITCH_TO_SWAP_FW_BW),
            lastDirection(NEXT),
            mustLoad(false),
            showDuplicates(false)
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
            im.clear();
            version++;
            swapCnt = SWITCH_TO_SWAP_FW_BW;
            pivot = 0;
            mustLoad = false;
        }
        
        size_t size() { return im.size(); }
        
        void set_keep(size_t idx, bool b);


        BOOL show(Direction_t xnext) {
            BOOL rv = NO;

            if (mustLoad) return rv;

            lastDirection = xnext;

            if (pivot >= size()) pivot = 0;


            if (im[pivot].state == ics::NOTLOADED)
            {
                mustLoad = true;
                return rv;
            }
            if (im[pivot].state == ics::LOADING)
            {
                //mustLoad = true;
                return rv;
            }

            pivot = go_to_next_valid(xnext, pivot);
            
            if (im[pivot].state == ics::INVALID) {
                [viewCtl showImage:nil
                          origSize:NSSize()];

                NSLog(@"no valid image");
                return rv;
            }
            
            if (im[pivot].state == ics::LOADED) {
                update_view();
                rv = YES;
            }
            
            
            reset_keep();
            run();
            return rv;
        }

        template<Direction_t direction>
        size_t goToImage(size_t pvt) {
            size_t idx;
            if (pvt >= size()) {
                NSLog(@"invalid pivot value!");
                pvt = 0;
            }
            for (idx = go(direction, pvt); idx!=pvt; idx = go(direction, idx)) {
                if (im[idx].state != ics::INVALID) break;
            }
            return idx;
        }



        BOOL show_next() {
            lastDirection = NEXT;
            if (FW < BW) {
                if (swapCnt == 0) {
                    std::swap(BW,FW);
                } else {
                    swapCnt--;
                }
            } else {
                swapCnt = SWITCH_TO_SWAP_FW_BW;
            }
            return show(NEXT);
        }
        
        BOOL show_prev() {
            lastDirection = PREV;
            if (FW > BW) {
                if (swapCnt == 0) {
                    std::swap(BW,FW);
                } else {
                    swapCnt--;
                }
            } else {
                swapCnt = SWITCH_TO_SWAP_FW_BW;
            }
            return show(PREV);
        }

        void ready();
        
        size_t get_position() {
            return pivot;
        }
        
        void ensure_not_buzy();
                
        void set_new_size(NSSize size);

        QQAttributes * get_attributes() { return attributes; }

    private:

        void run();

        void update_view();
        

        size_t go_to_next_valid(Direction_t direction, size_t idx) {
            for (size_t i = go(direction, idx);i!=idx; i = go(direction, i)) {
                if (im[i].state != ics::INVALID) return i;
            }
            return idx;
        }

        size_t go(Direction_t direction, size_t idx) {
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


        size_t todo_(Direction_t direction) {
            size_t mem = 4 * cachedImageSize.width * cachedImageSize.height;
            size_t bw;
            if (direction == NEXT) {
                bw = FW;
            } else {
                bw = BW;
            }
            for(size_t idx = go(direction, pivot);
                idx != pivot;idx = go(direction, idx))
            {
                int state = im[idx].state;

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
        size_t todo_sha1();

        QQCacheInfo * get_cache_info();
        void notify_delegate();

    private:
        typedef std::vector<s::ImageLoader_t> Loaders_t;
        Loaders_t loaders;
        id<QQImageCtl> viewCtl;
        images_t im;
        ns::base_t<QQAttributes> attributes;
        size_t pivot;
        size_t BW, FW;
        int version;
        Direction_t lastDirection;
        NSSize cachedImageSize;
        int swapCnt;
        bool mustLoad;
        bool showDuplicates;
    };
}

