//
//  Web.m
//  MainWindow
//
//  Created by midoks on 2021/1/21.
//

#import "Web.h"
#import "Masonry.h"

@interface Web ()<NSWindowDelegate,NSTableViewDelegate,NSTableViewDataSource>
{
    NSView *titleBarView;
}

@property (weak) IBOutlet  NSTableView *listTableView;
@property (weak) NSView *wTitleBarView;
@property (weak) IBOutlet NSView *wTopView;
@property (weak) IBOutlet NSView *wContentView;
@property (strong) IBOutlet NSStackView *titleBarSVView;

@property (weak) IBOutlet NSStackView *wTitleBarStackView;
@property (strong) IBOutlet NSView *wTitleBarStackLeftView;
@property (strong) IBOutlet NSView *wTitleBarStackCenterView;
@property (strong) IBOutlet NSView *wTitleBarStackRightView;
@property (weak) IBOutlet NSStackView *wTopViewSView;
@property (weak) IBOutlet NSView *titleBarLeftView;
@property (strong) IBOutlet NSSearchField *wSearchView;


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
    
    [self initTableView];
    [self initTitleBarView];
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
    
    self.wTitleBarStackLeftView.wantsLayer = YES;
    self.wTitleBarStackLeftView.layer.backgroundColor = [NSColor blueColor].CGColor;
    
    
    [_wTitleBarView addSubview:_titleBarSVView];
    _titleBarSVView.layer.backgroundColor =[NSColor redColor].CGColor;
    [_wTitleBarStackView addView:_wTitleBarStackLeftView inGravity:NSStackViewGravityLeading];
    [_wTitleBarStackView setVisibilityPriority:NSStackViewVisibilityPriorityMustHold forView:_wTitleBarStackLeftView];
    
    [_wTitleBarStackView addView:_wTitleBarStackCenterView inGravity:NSStackViewGravityTrailing];
    [_wTitleBarStackView setVisibilityPriority:NSStackViewVisibilityPriorityMustHold forView:_wTitleBarStackCenterView];
    
//    [_wTitleBarStackView addView:_wTitleBarStackRightView inGravity:NSStackViewGravityTrailing];
//    [_wTitleBarStackView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_wTitleBarStackRightView];
}


#pragma mark - NSTableView
-(void)initTableView{
    
    NSLog(@"%@", NSStringFromRect(self.window.contentView.bounds));
        
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    
    NSLog(@"initTableView");
//    self.listTableView.gridColor = [NSColor blueColor];
//    [self.listTableView reloadData];
    
}


#pragma mark - NSTableViewDelegate, NSTableViewDataSource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
//    NSLog(@"numberOfRowsInTableView");
    return 100;
}


-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
//    NSLog(@"objectValueForTableColumn");
    return @"精选";
}


-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 28;
}


-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSLog(@"demo");
}

@end
