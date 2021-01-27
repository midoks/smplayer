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

@property (weak) IBOutlet  NSTableView *listTableView;
@property (weak) NSView *wTitleBarView;
@property (weak) IBOutlet NSView *wTopView;
@property (weak) IBOutlet NSView *wContentView;



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
    
    
    
    SMTabListView *smtv = [[SMTabListView alloc] init];
    
    smtv.wantsLayer = YES;
    smtv.layer.backgroundColor = [NSColor whiteColor].CGColor;
    [_wContentView addSubview:smtv];
    
    [smtv mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@5);
        make.right.equalTo(@5);
        make.top.equalTo(@5);
        make.bottom.equalTo(@0);
    }];
    
    
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

}


#pragma mark - NSTableView
-(void)initTableView{
    
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    
    NSLog(@"initTableView");
}



#pragma mark - NSTableViewDelegate, NSTableViewDataSource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return 100;
}


-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return @"精选";
}


-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 36;
}



-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSLog(@"demo");
}

@end
