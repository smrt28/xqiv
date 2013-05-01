//
//  QQStruct.m
//  xqiv
//
//  Created by smrt on 5/1/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQStruct.h"

@implementation QQNSSize

-(id)init {
    self = [super init];
    self.height = 0;
    self.width = 0;
    return self;
}

- (NSSize)size {
    NSSize rv;
    rv.width = self.width;
    rv.height = self.height;
    return rv;
}

+ (QQNSSize *)sizeWithNSSize:(NSSize)size {
    QQNSSize *rv = [[[QQNSSize alloc] init] autorelease];
    rv.width = size.width;
    rv.height = size.height;
    return rv;
}

+ (QQNSSize *)sizeWithScreenSize {
    NSSize screenFrame = [[NSScreen mainScreen] visibleFrame].size;
    return [QQNSSize sizeWithNSSize:screenFrame];
}

@end
