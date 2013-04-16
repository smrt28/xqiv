//
//  QQCache.h
//  xqiv
//
//  Created by smrt on 3/23/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QQImageLoader.h"

#import "ns-array.h"
#import "ns-dict.h"

@protocol QQCacheProtocol<NSObject>
- (void)showCachedImage:(NSDictionary *)item;
@end

namespace s { class Cache_t; }

@interface QQCache : NSObject<QQImageLoaderProtocol> {
    s::Cache_t * _cache;
    QQImageLoader *_imageLoader;
}

- (BOOL)buzy;
- (void)imageLoaded:(NSMutableDictionary *)obj;
- (id)initWithCache:(s::Cache_t *)cache;
- (void)invalidate;

@end


namespace s {

    size_t get_item_index(NSMutableDictionary * anItem);
    
    class Cache_t {

    public:
        Cache_t() :
            array(),
            position(0),
            qqCache([[QQCache alloc] initWithCache:this]),
            delegate(nil),
            nextPosition(-1)
        {}
        
        ~Cache_t() {
            [delegate release];
            [qqCache release];
        }
        
        
        void insert(ns::dict_t &dict);
        void go();

        void next();
        
        void prev();
        
        void positionChanged();
        
        
        void update(NSMutableDictionary *);
        
        size_t size() { return array.size(); }
        
        void clear() {
            nextPosition = 0;
            position = 0;
            array.clear();
            [qqCache invalidate];
        }
        
        
        void setDelegate(id<QQCacheProtocol> dlg) {
            [delegate release];
            delegate = dlg;
            [delegate retain];
        }
        
        void handleLoaded(NSMutableDictionary *item);
    private:
        size_t pos() { return position; }

        NSMutableDictionary * get();
        
        NSMutableDictionary * get(size_t);
        
        size_t get_todo();
        
        bool is_to_clear(size_t ofs);
        
        void logCache();
    private:
        ns::array_t array;
        long position;
        QQCache * qqCache;
        id<QQCacheProtocol> delegate;
        long nextPosition;
    };
}