//
//  Preference.m
//  smplayer
//
//  Created by midoks on 2020/3/9.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "Preference.h"

@interface Preference ()<NSTableViewDelegate,NSTableViewDataSource>

@property (weak) IBOutlet NSTableView *listTableView;
@end

@implementation Preference

//
-(id)init{
    self = [self initWithWindowNibName:@"Preference"];
     
//       [self.listTableView reloadData];
    return self;
}
-(id)initWithWindow:(NSWindow *)window
{
    if (self = [super initWithWindow:window]) {
        [self loadWindow];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    
//    self.listTableView.delegate = self;
//    self.listTableView.dataSource = self;
}


#pragma mark - NSTableViewDelegate, NSTableViewDataSource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    NSLog(@"numberOfRowsInTableView");
    return 5;
}


- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTableCellView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    [cell.textField setStringValue:@"dd"];
//    [cell.textField setEditable:NO];
//    [cell.textField setDrawsBackground:NO];
    return cell;
}


//-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
//    NSLog(@"objectValueForTableColumn");
//    NSLog(@"%@",[NSString stringWithFormat:@"%ld", row]);
////    return [NSString stringWithFormat:@"%ld", row];
//    return @{@"n":@"dd.mp4"};
////    return nil;
//}


-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSLog(@"ddd");
}

@end
