//
//  QQImageLoader.h
//  xqiv
//
//  Created by smrt on 3/19/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "as.h"

@protocol QQImageLoaderProtocol<NSObject>
    - (void)imageLoaded:(NSMutableDictionary *)obj;
@end



@interface QQImageLoader : NSThread {
    BOOL _end;
    id _target;
    NSThread *_thread;
    id<QQImageLoaderProtocol> _delegate;
    BOOL _inProgress;
}



+ (QQImageLoader *)loader;
- (BOOL)loadImage:(NSString *)filename userData:(id)data;
- (void)join;
- (void)setDelegate:(id<QQImageLoaderProtocol>)delegate;
- (id)delegate;
- (BOOL)inProgress;
- (void)ensureWaiting;

@end


namespace s {
    class ImgLoaderListener_t {
    public:
        virtual void loaded(NSMutableDictionary *) = 0;
    };
}

@interface QQImageLoaderCBridge : NSObject<QQImageLoaderProtocol> {
    s::ImgLoaderListener_t * _c;

}

- (void)setC:(s::ImgLoaderListener_t *)c;
- (void)imageLoaded:(NSMutableDictionary *)obj;

@end


namespace s {
    class ImageLoader_t : public ns::base_t<QQImageLoader> {
    public:
        ImageLoader_t(ImgLoaderListener_t *listener) : ns::base_t<QQImageLoader>() {
            NSLog(@"ImageLoader_t created");
            QQImageLoaderCBridge * bridge =
                [[QQImageLoaderCBridge alloc] init];
            [bridge setC:listener];
            [o setDelegate: bridge];
            [bridge release];
            [o start];
        }
        
        bool load(NSString *filename, id ud) {
            if ([o loadImage: filename userData:ud]) return true;
            return false;
        }
        
        bool inProgress() {
            if ([o inProgress]) return true;
            return false;
        }
        
        void ensure_not_buzy() {
            [o ensureWaiting];
        }
    };
}
