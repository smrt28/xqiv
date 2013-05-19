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
                attributes:attr(false).objc()
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
        NSSize originalsize = [d[@"originalsize"].as<QQNSSize>() size];
        NSLog(@"loaded: %zd", idx);

        QQCacheItem * cache = im[idx];

        if (d[@"errorcode"].as<int>() != 0) {
            cache.image = nil;
            cache.state = ics::INVALID;
            if (lastAction && pivot == idx) {
                (this->*lastAction)();
            }
            return;
        }

        cache.image = img;
        cache.state = ics::LOADED;
        cache.originalsize = originalsize;


        cache.sha1 = d[@"sha1"].as<NSString>();
        if (idx == pivot) {
            update_view();
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
            if (td == NOINDEX) return;

            ns::dict_t udata;
            udata.insert(@"index", [NSNumber numberWithLong:td]);
            udata.insert(@"version", [NSNumber numberWithLong:version]);
            udata.insert(@"size", [QQNSSize sizeWithNSSize:cachedImageSize]);

            NSString *filename = im[td].filename;
            im[td].state = ics::LOADING;
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


        for(size_t idx = go<NEXT>(pivot);idx != pivot;idx = go<NEXT>(idx)) {
            if (im[idx].state == ics::INVALID) continue;
            im[idx].keep = true;
            if (fw < mem) break;
            fw -= mem;
        }

        for(size_t idx = go<PREV>(pivot);idx != pivot;idx = go<PREV>(idx)) {
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

        if (FW > BW) {
            rv = todo_<NEXT>();
            if (rv == NOINDEX) {
                rv = todo_<PREV>();
            }
        } else {
            rv = todo_<PREV>();
            if (rv == NOINDEX) {
                rv = todo_<NEXT>();
            }
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

    ns::dict_t ImageCache_t::attr(bool create) {
        NSString *sha1 = im[pivot].sha1;
        if (!sha1) return ns::dict_t();


        if (!attributes[sha1]) {
            if (!create) {
                return ns::dict_t(nil);
            }
            ns::dict_t rv;
            attributes.insert(sha1, rv);
            return rv;
        }

        return attributes[sha1].as<ns::dict_t>();
    }

    bool ImageCache_t::hasAttr() {
        NSString *sha1 = im[pivot].sha1;
        if (!sha1) return false;
        if (!attributes[sha1]) return false;
        return true;
    }

    NSString * ImageCache_t::get_attribute(NSString *key) {
        return attr()[key].as<NSString>();
    }

    void ImageCache_t::set_attribute(NSString *key, NSString *value) {
        attr().insert(key, value);
    }

    void ImageCache_t::set_new_size(NSSize sz) {
        cachedImageSize = sz;
        im.reload();
        run();
    }


    void ImageCache_t::saveAttributes() {
        NSString *xqivAttrs = [@"~/.xqivattrs" stringByExpandingTildeInPath];
        NSMutableDictionary *md = attributes.objc();
        BOOL ok = [md writeToFile:xqivAttrs atomically:YES];
        ok = NO;
    }

    void ImageCache_t::loadAttributes() {
        NSString *xqivAttrs = [@"~/.xqivattrs" stringByExpandingTildeInPath];
        NSMutableDictionary * at =
            [NSMutableDictionary dictionaryWithContentsOfFile:xqivAttrs];
        if (at) attributes = at;
    }
}

