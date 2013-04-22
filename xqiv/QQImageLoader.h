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
    BOOL _invalied;
}



+ (QQImageLoader *)loader;
- (BOOL)loadImage:(NSMutableDictionary *)item index:(size_t)idx;
- (void)join;
- (void)setDelegate:(id<QQImageLoaderProtocol>)delegate;
- (id)delegate;
- (BOOL)inProgress;
- (void)invalidate;

@end


namespace s { class image_loader_t; }

@interface QQImageLoaderCBridge : NSObject<QQImageLoaderProtocol> {
    s::image_loader_t *_c;
}

- (void)setC:(s::image_loader_t *)c;
- (void)imageLoaded:(NSMutableDictionary *)obj;

@end


namespace s {
    class image_loader_t : public ns::base_t<QQImageLoader> {
    public:
        image_loader_t() : ns::base_t<QQImageLoader>() {
            QQImageLoaderCBridge * bridge =
                [[QQImageLoaderCBridge alloc] init];
            [bridge setC:this];
            [o setDelegate: bridge];
            [bridge release];
            [o start];
        }
        void loaded(NSMutableDictionary *) {
            
        }
    private:
    };
}
