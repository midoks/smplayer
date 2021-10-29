//
//  Web.m
//  MainWindow
//
//  Created by midoks on 2021/1/21.
//

#import "Web.h"
#import "Masonry.h"

#import "SMTabListView.h"

@interface Web ()<NSWindowDelegate,NSTableViewDelegate,NSTableViewDataSource>
{
    NSView *titleBarView;
}

@property (strong, nonatomic) IBOutlet  NSTableView *listTableView;
@property (weak) NSView *wTitleBarView;
@property (weak) IBOutlet NSView *wTopView;
@property (weak) IBOutlet NSView *wContentView;

@property (strong, nonatomic) NSCollectionView *collectView;

@property (strong,nonatomic) SMTabListView *selectList;
@end

@implementation Web

static Web *_instance = nil;
static dispatch_once_t _instance_once;
+ (id)Instance{
    dispatch_once(&_instance_once, ^{
        _instance = [[Web alloc] init];
    });
    return _instance;
}

-(id)init{
    self = [self initWithWindowNibName:@"Web"];
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
    
    self.window.movableByWindowBackground = YES;
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = YES;
    [self.window setCollectionBehavior:NSWindowCollectionBehaviorFullScreenAuxiliary];
    
    
    
    NSButton *zoomBtn = [self.window standardWindowButton:NSWindowZoomButton];
    NSView *s = [zoomBtn superview];
    titleBarView = [s superview];
    [self setTitleBarBtnView:self.window.frame.size];
    
 
    [self initTitleBarView];
    
//    _selectList = [[SMTabListView alloc] initWithFrame:self.contentViewController.view.bounds];
//    _selectList.wantsLayer = YES;
//    [_wContentView addSubview:_selectList];
//
//    [_selectList mas_remakeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(@5);
//        make.right.equalTo(@150);
//        make.top.equalTo(@5);
//        make.bottom.equalTo(@10);
//    }];
    
    
    _collectView = [[NSCollectionView alloc] initWithFrame:self.contentViewController.view.bounds];
    [_wContentView addSubview:_collectView];
}

-(void)windowWillEnterFullScreen:(NSNotification *)notification{
    NSLog(@"ddd");
}

-(void)windowWillExitFullScreen:(NSNotification *)notification{
    NSLog(@"ddd exit");
}

-(void)setTitleBarBtnView:(NSSize)size{
    
    _wTopView.wantsLayer = YES;
    _wTopView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    _wContentView.wantsLayer = YES;
    _wContentView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    NSShadow *shadow = [[NSShadow alloc] init];
    [shadow setShadowColor:[NSColor grayColor]];
    [shadow setShadowOffset:NSMakeSize(10, 10)];
    [_wTopView setFrame:NSMakeRect(0, 0, _wTopView.frame.size.width, 50)];
    [_wTopView setShadow:shadow];
    
    [titleBarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@15);
        make.right.equalTo(@0);
        make.top.equalTo(@0);
        make.height.mas_equalTo(60);
    }];

    NSButton *closeBtn = [self.window standardWindowButton:NSWindowCloseButton];
    NSButton *zoomBtn = [self.window standardWindowButton:NSWindowZoomButton];
    NSButton *minBtn = [self.window standardWindowButton:NSWindowMiniaturizeButton];

    for (NSView *buttonView in @[closeBtn, zoomBtn, minBtn]) {
        [buttonView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(buttonView.superview.mas_centerY);
        }];
    }
}

-(void)initTitleBarView{
    _wTitleBarView.wantsLayer = YES;
    _wTitleBarView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    
    [self.listTableView reloadData];

}

#pragma mark - NSTableViewDelegate, NSTableViewDataSource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return 10;
}


-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 36;
}

- (NSView*)tableView:(NSTableView*)tableView viewForTableColumn:(NSTableColumn*)tableColumn row:(NSInteger)row
{
    
    NSString *title = @"电影";
    NSTableCellView *cell = [tableView makeViewWithIdentifier:tableColumn.identifier owner:self];
    [cell.textField setStringValue:title];
    [cell.textField setFont:[NSFont boldSystemFontOfSize:14]];
    NSRect _frame = cell.textField.frame;
    cell.textField.frame = NSMakeRect(20, 0, _frame.size.width, _frame.size.height);
    cell.textField.alignment =NSTextAlignmentCenter;
    
    return cell;
}

- (NSDragOperation)tableView:(NSTableView *)tableView validateDrop:(id<NSDraggingInfo>)info proposedRow:(NSInteger)row proposedDropOperation:(NSTableViewDropOperation)dropOperation
{
    if (dropOperation == NSTableViewDropAbove) {
        return NSDragOperationNone;
    }
    return NSDragOperationMove;
}

- (NSString *)tableView:(NSTableView *)tableView toolTipForCell:(NSCell *)cell rect:(NSRectPointer)rect tableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row mouseLocation:(NSPoint)mouseLocation{
    return @"tip";
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSLog(@"demo");
}

@end
