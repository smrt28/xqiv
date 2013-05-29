//
//  QQInfoWindowController.m
//  xqiv
//
//  Created by smrt on 5/18/13.
//  Copyright (c) 2013 smrt. All rights reserved.
//

#import "QQInfoWindowController.h"

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
-(void)awakeFromNib {
   // [_labels ]
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

        [_loaded setStringValue:[NSString stringWithFormat:@"%d/%d",
                                 info.loadedFw, info.total]];
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
