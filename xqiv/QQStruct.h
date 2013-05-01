//
//  QQStruct.h
//  xqiv
//
//  Created by smrt on 5/1/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QQNSSize : NSObject
+ (QQNSSize *)sizeWithNSSize:(NSSize)size;
+ (QQNSSize *)sizeWithScreenSize;
- (NSSize)size;
@property (readwrite) CGFloat width;
@property (readwrite) CGFloat height;
@end


