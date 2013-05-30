//
//  QQAttributes.m
//  xqiv
//
//  Created by smrt on 5/22/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQAttributes.h"

@implementation QQAttributes
-(id)init {
    self = [super init];
    _dict = _forFile = nil;
    _sha1 = nil;
    _modified = NO;
    return self;
}

- (void)dealloc {
    [self flush];
    [_dict release];
    [super dealloc];
}

- (void)save {
    [self save:@"~/.xqivattrs"];
}

- (void)save:(NSString *)filename {
    [self flush];
    NSString *xqivAttrs = [filename stringByExpandingTildeInPath];
    [_dict writeToFile:xqivAttrs atomically:YES];
}

- (void)load {
    [self load:@"~/.xqivattrs"];
}

- (void)load:(NSString *)filename {
    NSString *xqivAttrs = [filename stringByExpandingTildeInPath];
    NSMutableDictionary * at =
    [NSMutableDictionary dictionaryWithContentsOfFile:xqivAttrs];
    if (!at) return;
    [_dict release];
    _dict = at;
    [_dict retain];
}

- (void)flush {
    if (_modified) {
        [_dict setObject:_forFile forKey:_sha1];
    }

    [_forFile release];
    [_sha1 release];
    _forFile = nil;
    _sha1 = nil;
    _modified = NO;
}

- (void)select:(QQCacheItem *)item {
    [self flush];

    NSString *sha1 = item.sha1;
    _sha1 = [sha1 retain];
    NSMutableDictionary *val = [_dict valueForKey:sha1];
    if (val) {
        _forFile = [val retain];
    } else {
        _forFile = [[NSMutableDictionary alloc] init];
    }
}

- (void)setValue:(NSString *)value forKey:(NSString *)key {
    NSString * orig = [_forFile objectForKey:key];
    if (orig && [orig compare:value] == NSOrderedSame) return;
    [_forFile setObject:value forKey:key];
    _modified = YES;
}

- (void)setIntValue:(int)value forKey:(NSString *)key {
    [self setValue:[NSString stringWithFormat:@"%d", value] forKey:key];
}

- (NSString *)getValueForKey:(NSString *)key {
    return [_forFile objectForKey:key];
}

- (int)getIntValueForKey:(NSString *)key {
    NSString *rv = [_forFile objectForKey:key];
    return [rv intValue];
}

@end
