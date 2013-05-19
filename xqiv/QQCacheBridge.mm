//
//  QQCacheBridge.m
//  xqiv
//
//  Created by smrt on 5/19/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQCacheBridge.h"


@implementation QQCacheItem
-(id)init {
    self = [super init];
    [self setFilename: nil];
    [self setImage: nil];
    [self setErrorcode: 0];
    self.state = s::ics::NOTLOADED;
    return self;
}

- (void)dealloc {
    [self setImage:nil];
    [self setSha1:nil];
    [self setFilename:nil];

    [super dealloc];
}
@end


@implementation QQCacheBridge

@end
