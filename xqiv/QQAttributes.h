//
//  QQAttributes.h
//  xqiv
//
//  Created by smrt on 5/22/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QQAttributes : NSObject {
    NSMutableDictionary *_dict;
    NSMutableDictionary *_forFile;
    BOOL _inDict;
    BOOL _modified;
    NSString *_sha1;
}
-(id)init;
@end
