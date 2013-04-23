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
@interface QQCacheItem : NSObject
@property (readwrite,retain) NSImage *image;
@property (readwrite,retain) NSString *filename;
@property (readwrite) int errorcode;
@property (readwrite) int itemId;
@end

namespace  s  {
    class ImageCache_t : public ImgLoaderListener_t {
    public:
        virtual ~ImageCache_t() {}
        ImageCache_t() :
            viewCtl(nil),
            nextItemId(0)
        {
            loaders.push_back(ImageLoader_t(this));
        }
        void loaded(NSMutableDictionary *);
        void setCtl(id<QQImageCtl> vctl) {
            [vctl retain];
            [viewCtl release];
            viewCtl = vctl;
        }
        
        void load(NSString *filename, id userData);
        
        QQCacheItem * push_back(NSString *filename);
        
        void clear() {
            images.clear();
        }
        
    private:
        typedef std::vector<s::ImageLoader_t> Loaders_t;
        Loaders_t loaders;
        id<QQImageCtl> viewCtl;
        ns::array_t images;
        int nextItemId;
    };
}

