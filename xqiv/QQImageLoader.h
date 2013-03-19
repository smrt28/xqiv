//
//  QQImageLoader.h
//  xqiv
//
//  Created by smrt on 3/19/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QQImageLoader : NSThread {
    NSCondition *_condition;
    NSCondition *_endCondition;
    
    NSLock *_lock;
    NSMutableArray *_jobs;
    BOOL _end;
    SEL _callback;
    id _target;
    NSThread *_thread;
}

+ (QQImageLoader *)loader:(SEL)callback target:(id)obj;
- (void)insertImageTask:(NSString *)filename;

//- (void)insert:(NSString *)file;

@end
