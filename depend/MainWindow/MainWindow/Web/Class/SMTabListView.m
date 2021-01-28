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
@property  NSTableView *tabList;

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
    
    _tabList = [[NSTableView alloc] initWithFrame:NSMakeRect(0, 0, 200, 100)];
    _tabList.wantsLayer = YES;
    _tabList.backgroundColor = [NSColor blueColor];
    _tabList.delegate = self;
    _tabList.dataSource = self;
    [self addSubview:_tabList];
    
    [_tabList mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.top.equalTo(@31);
        make.height.mas_equalTo(100);
    }];
    
    [_tabList reloadData];
    
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

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    NSLog(@"tableView");
    return @"精选";
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 36;
}

- (NSView*)tableView:(NSTableView*)tableView viewForTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)row
{
    NSLog(@".....");
    NSTableCellView *cell = [tableView makeViewWithIdentifier:@"NSTableCellView_Sign" owner:self];
    cell.textField.stringValue = @"ddd";
    cell.layer.backgroundColor= [NSColor redColor].CGColor;
    return cell;
}
//
- (NSString *)tableView:(NSTableView *)tableView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation{
    NSLog(@".....");
    return @"tip";
}
@end
