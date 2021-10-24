//
//  SMTabListView.m
//  MainWindow
//
//  Created by midoks on 2021/1/28.
//

#import "Masonry.h"

#import "SMTabListView.h"

@interface SMTabListView()<NSWindowDelegate,NSTableViewDelegate,NSTableViewDataSource>

@property  NSView *bList;
@property  NSTableView *tableView;

@end

@implementation SMTabListView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    }
    
//    self.wantsLayer = YES;
//    self.layer.backgroundColor = [NSColor grayColor].CGColor;
    
    _bList = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 200, 30)];
    _bList.wantsLayer = TRUE;
    _bList.layer.backgroundColor = [NSColor redColor].CGColor;
    [self addSubview:_bList];
    
    
    [_bList mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.top.equalTo(@0);
        make.height.mas_equalTo(30);
    }];
    
    NSArray *list = @[@"推荐",@"科幻",@"冒险",@"爱情",@"都市",@"历史",@"更多分类"];
    
    NSInteger i = 0;
    NSInteger width = 80;
    for (NSString *title in list) {
        i++;
        [self addItem:title width:width pos:(i-1)*width];
    }
    
//    _tableView = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 0, 0)];

//    _tableView.wantsLayer = YES;
//    _tableView.backgroundColor = [NSColor blueColor];
//    _tableView.delegate = self;
//    _tableView.dataSource = self;
//    _tableView.
//    [_tableView setGridColor:[NSColor blackColor]];
//    [_tableView setRowSizeStyle:NSTableViewRowSizeStyleLarge];
//    [_tableView setGridStyleMask:(NSTableViewSolidHorizontalGridLineMask | NSTableViewSolidVerticalGridLineMask)];
//    [[_tableView cell] setLineBreakMode:NSLineBreakByTruncatingTail];
//    [[_tableView cell] setTruncatesLastVisibleLine:YES];
//    [_tableView setColumnAutoresizingStyle:NSTableViewSequentialColumnAutoresizingStyle];
//    [_tableView setUsesAlternatingRowBackgroundColors:NO];
//    [_tableView.headerView setHidden:YES];
    
//    [_tableView setUsesAlternatingRowBackgroundColors:NO];
    
//    NSTableColumn *column = [[NSTableColumn alloc] initWithIdentifier:@"field1"];
//    [_tableView addTableColumn:column];
    
//    [self addSubview:_tableView];
    
//    [_tableView mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(@0);
//        make.right.equalTo(@0);
//        make.top.equalTo(@31);
//        make.height.mas_equalTo(100);
//    }];
//
//    [_tableView reloadData];
    
    return self;
}

-(void)addItem:(NSString *)title width:(NSInteger)width pos:(NSInteger)pos{
    NSButton *b = [[NSButton alloc] initWithFrame:NSMakeRect(pos, 0, width, 30)];
    b.wantsLayer = YES;
    b.layer.cornerRadius = 6.0f;
    b.layer.borderWidth = 0.f;
//    b.layer.opacity = 0.8;
    b.bezelStyle = NSBezelStyleRegularSquare;
    b.transparent = NO;
    [b setBordered:NO];
    [b setFont:[NSFont systemFontOfSize:14]];
    [b setTitle:title];
    [_bList addSubview:b];
}

#pragma mark - NSTableViewDelegate, NSTableViewDataSource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return 30;
}

//-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
//    NSLog(@"tableView");
//    return @"精选";
//}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 36;
}

- (NSView*)tableView:(NSTableView*)tableView viewForTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)row
{
    NSString *title = @"电影";
    NSTableCellView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    [cell.textField setStringValue:title];
    [cell.textField setFont:[NSFont boldSystemFontOfSize:14]];
    [cell.textField setEditable:NO];
    [cell.textField setDrawsBackground:NO];
    return cell;
}
//
- (NSString *)tableView:(NSTableView *)tableView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation{
    NSLog(@".....??");
    return @"tip";
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSLog(@"demo");
    [_tableView deselectAll:NULL];
}
@end
