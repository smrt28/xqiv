//
//  QQInfoWindowController.m
//  xqiv
//
//  Created by smrt on 5/18/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQInfoWindowController.h"
#import "QQAttributes.h"

@interface QQInfoWindowController ()

@end

@implementation QQInfoWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)dealloc {
    [_star64 release];
    [_star64rb release];
    [super dealloc];
}

-(void)awakeFromNib {
    NSString* imageName = [[NSBundle mainBundle]
                           pathForResource:@"star64" ofType:@"png"];
    _star64 = [[NSImage alloc] initWithContentsOfFile:imageName];

    imageName = [[NSBundle mainBundle]
                           pathForResource:@"star64rb" ofType:@"png"];
    _star64rb = [[NSImage alloc] initWithContentsOfFile:imageName];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

-(void) update:(QQCacheItem *)item cacheInfo:(QQCacheInfo *)info {

    if (item) {
        _item.reset(item);
        [_sha1 setStringValue:item.sha1];
        [_filename setStringValue:item.filename];
    }
    if (info) {
        _info.reset(info);
        [_loaded setStringValue:[NSString stringWithFormat:@"(%d) %d/%d",
                                 int(info.pivot), info.loadedFw, info.total]];
    }

    if (!_item) return;

    [_attributes select:_item];
    int star = [_attributes.objc() getIntValueForKey:@"star"];
    if (star) {
        [_star setState:NSOnState];
        [self updateStar:1];

    } else {

        [_star setState:NSOffState];
        [self updateStar:0];

    }
}

-(IBAction)copyButton:(id)sender {
    NSPasteboard *pasteBoard = [NSPasteboard generalPasteboard];
    [pasteBoard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
    [pasteBoard setString: [_item.objc() filename] forType:NSStringPboardType];
}

-(IBAction)showInFinder:(id)sender {
    [[NSWorkspace sharedWorkspace] selectFile:[_item.objc() filename] inFileViewerRootedAtPath:nil];
}

-(void)setAttributes:(QQAttributes *)attributes {
    _attributes.reset(attributes);
}

-(void)updateStar:(int)val {
    if (val)
        [_starImage setImage:_star64];
    else
        [_starImage setImage:_star64rb];
}

-(IBAction)starButton:(id)sender {
    
    NSInteger star = [_star state];
    [_attributes.objc() select:_item];

    if (star == NSOnState) {
        [self updateStar:1];
        [_attributes.objc() setValue:@"1" forKey:@"star"];
    } else if (star == NSOffState) {
        [self updateStar:0];
        [_attributes.objc() setValue:@"0" forKey:@"star"];
    }
}
/*
- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSString *identifier = [tableColumn identifier];
    NSTableCellView *cellView = [tableView makeViewWithIdentifier:identifier owner:self];
    cellView.textField.stringValue = @"aaax";
    return cellView;
}

// The only essential/required tableview dataSource method
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return 1;
}
 */
@end
