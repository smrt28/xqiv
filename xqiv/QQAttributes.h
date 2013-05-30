//
//  QQAttributes.h
//  xqiv
//
//  Created by smrt on 5/22/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "QQCacheBridge.h"

@interface QQAttributes : NSObject {
    NSMutableDictionary *_dict;
    NSMutableDictionary *_forFile;
    BOOL _modified;
    NSString *_sha1;
}

- (NSString *)getValueForKey:(NSString *)key;
- (int)getIntValueForKey:(NSString *)key;

- (void)select:(QQCacheItem *)item;
- (void)setValue:(NSString *)value forKey:(NSString *)key;
- (void)setIntValue:(int)value forKey:(NSString *)key;
- (void)save;
- (void)load;
- (id)init;

@end
