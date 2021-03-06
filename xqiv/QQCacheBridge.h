//
//  QQCacheBridge.h
//  xqiv
//
//  Created by smrt on 5/19/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>

namespace s {
    namespace ics {
        static const int INVALID = 0;
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
@property (readwrite) bool duplicate;

@end

@interface QQCacheInfo : NSObject
@property (readwrite) int loaded;
@property (readwrite) int total;
@property (readwrite) int loadedFw;
@property (readwrite) size_t pivot;
@property (readwrite) size_t cnt;
@end


@protocol QQImageCtl<NSObject>
- (void)showImage:(QQCacheItem *)img
         origSize:(NSSize)size;

- (void)cacheStateChanged:(QQCacheInfo *)cacheInfo;
@end

@interface QQCacheBridge : NSObject

@end
