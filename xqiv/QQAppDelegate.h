//
//  QQAppDelegate.h
//  xqiv
//
//  Created by smrt on 3/16/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "QQImageView.h"

@interface QQAppDelegate : NSObject <NSApplicationDelegate> {
    IBOutlet QQImageView * image;

}

- (IBAction) test:sender;


@property (assign) IBOutlet NSWindow *window;

@end
