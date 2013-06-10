    //
//  imagecache.cpp
//  xqiv
//
//  Created by smrt on 4/21/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQStruct.h"
#import "imagecache.h"
#import "ns-dict.h"

#include <set>



namespace s {

    void ImageCache_t::update_view() {
        [viewCtl showImage:im[pivot]
                  origSize:im[pivot].originalsize];
    }

    void ImageCache_t::loaded(NSMutableDictionary *aDict) {
        ns::dict_t d(aDict);

        NSImage *img = d[@"image"].as<NSImage>();
        ns::dict_t udata(d[@"userdata"]);
        if (udata[@"version"].as<int>() != version) {
            run();
            return;
        }

        size_t idx = udata[@"index"].as<int>();
        if (idx == pivot) mustLoad = false;
        NSSize originalsize = [d[@"originalsize"].as<QQNSSize>() size];
        NSLog(@"loaded: %zd", idx);

        QQCacheItem * cache = im[idx];
        if (cache.state == ics::INVALID) {
            run();
            return;
        }

        size_t dupl = im.find_sha1(d[@"sha1"].as<NSString>());

        if (!showDuplicates && dupl != im.size() && dupl != idx) {
            cache.state = ics::INVALID;
            cache.image = nil;
            cache.duplicate = true;
            NSLog(@"duplicate detected!");
            if (pivot == idx) {
                show(lastDirection);
            }
            run();
            return;
        }

        if (d[@"errorcode"].as<int>() != 0) {
            cache.image = nil;
            cache.state = ics::INVALID;
            if (pivot == idx) {
                show(lastDirection);
            }
            notify_delegate();
            return;
        }

        if (img) {
            cache.image = img;
            cache.state = ics::LOADED;
            cache.originalsize = originalsize;
            cache.sha1 = d[@"sha1"].as<NSString>();
            if (idx == pivot) {
                update_view();
            }
            notify_delegate();
        } else {
            NSLog(@"got sha1 only...");
            cache.sha1 = d[@"sha1"].as<NSString>();
        }

        run();
    }


    void ImageCache_t::ensure_not_buzy() {
        for(Loaders_t::iterator it = loaders.begin(),
            eit = loaders.end();
            it != eit; ++it)
        {
            it->ensure_not_buzy();

        }
    }


    void ImageCache_t::run() {
        for(Loaders_t::iterator it = loaders.begin(),
            eit = loaders.end();
            it != eit; ++it)
        {
            if (it->inProgress()) continue;

            size_t td = todo();
            

            ns::dict_t udata;
            if (td != NOINDEX) {
                udata.insert(@"size", [QQNSSize sizeWithNSSize:cachedImageSize]);
                im[td].state = ics::LOADING;
            } else {
                td = todo_sha1();
                if (td == NOINDEX) return;
            }

            udata.insert(@"index", [NSNumber numberWithLong:td]);
            udata.insert(@"version", [NSNumber numberWithLong:version]);

            NSString *filename = im[td].filename;
            
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


    void ImageCache_t::reset_keep() {
        for (size_t i = 0; i < size(); i++) {
            im[i].keep = false;
        }

        size_t mem = 4 * cachedImageSize.width * cachedImageSize.height;

        // 400MB forward
        size_t fw = FW;

        // 100MB backward
        size_t bw = BW;
        im[pivot].keep = true;


        for(size_t idx = go(NEXT, pivot);idx != pivot;idx = go(NEXT, idx)) {
            if (im[idx].state == ics::INVALID) continue;
            im[idx].keep = true;
            if (fw < mem) break;
            fw -= mem;
        }

        for(size_t idx = go(PREV, pivot);idx != pivot;idx = go(PREV, idx)) {
            if (im[idx].state == ics::INVALID) continue;
            im[idx].keep = true;
            if (bw < mem) break;
            bw -= mem;
        }

        for (size_t i = 0; i < size(); i++) {
            if (!im[i].keep) {
                im.unload(i);
            }
        }
        notify_delegate();
    }


    size_t ImageCache_t::todo_sha1() {
        for(size_t idx = 0; idx < im.size(); idx++) {
            if (im[idx].sha1) continue;
            if (im[idx].state == ics::INVALID) continue;
            return idx;
        }

        return NOINDEX;
    }

    size_t ImageCache_t::todo() {
        if (size() == 0) return NOINDEX;

        size_t mem = 4 * cachedImageSize.width * cachedImageSize.height;

        //NSLog(@"Image size: %ld", mem);

        //int bw = BW, fw = FW;

        // 400MB forward
        size_t fw = FW;

        // 100MB backward
        size_t bw = BW;

        if (aux::need_reload(im[pivot].state)) {
            return pivot;
        }

        size_t rv;
        rv = todo_(lastDirection);
        if (rv == NOINDEX) {
            rv = todo_(lastDirection == NEXT ? PREV : NEXT);
        }
        return rv;
    }

    QQCacheItem * ImageCache_t::push_back(NSString *filename) {
        if (!filename) {
            NSLog(@"pushing nil to cache");
            return nil;
        }
        QQCacheItem * item = [[[QQCacheItem alloc] init] autorelease];
        item.filename = filename;
        im.push_back(item);
        return item;
    }



    void ImageCache_t::set_new_size(NSSize sz) {
        cachedImageSize = sz;
        im.reload();
        run();
    }


    QQCacheInfo * ImageCache_t::get_cache_info() {
        QQCacheInfo * rv = [[[QQCacheInfo alloc] init] autorelease];
        rv.loaded = 0;
        rv.total = 0;
        for(size_t i = 0; i < size(); i++) {
            if (im[i].state == ics::LOADED) rv.loaded = rv.loaded + 1;
            if (im[i].state != ics::INVALID) rv.total = rv.total + 1;
        }

        size_t cnt = 0;
        for(size_t idx = go_to_next_valid(lastDirection, pivot);
            idx != pivot;idx = go_to_next_valid(lastDirection, idx))
        {
            if (im[idx].state == ics::NOTLOADED) break;
            if (im[idx].state == ics::LOADED) cnt++;
        }
        rv.loadedFw = cnt;
        rv.pivot = pivot;
        rv.cnt = im.size();

        return rv;
    }

    void ImageCache_t::notify_delegate() {
        QQCacheInfo * rv = get_cache_info();
        [viewCtl cacheStateChanged:rv];
    }
}

