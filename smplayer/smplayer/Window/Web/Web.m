//
//  Web.m
//  smplayer
//
//  Created by midoks on 2020/3/9.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "Web.h"
#import "Masonry.h"

@interface Web ()<NSWindowDelegate,NSTableViewDelegate,NSTableViewDataSource>
{
    NSView *titleBarView;
    BOOL isFullScreen;
}

@property (weak) IBOutlet NSTableView *listTableView;

@end

@implementation Web

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
    
    isFullScreen = NO;
    
    NSButton *zoomBtn = [self.window standardWindowButton:NSWindowZoomButton];
    NSView *s = [zoomBtn superview];
    titleBarView = [s superview];
    [self setTitleBarView:self.window.frame.size];
}

-(void)windowWillEnterFullScreen:(NSNotification *)notification{
    isFullScreen = YES;
    [self setTitleBarView:self.window.frame.size];
}

-(void)windowWillExitFullScreen:(NSNotification *)notification{
    isFullScreen = NO;
    [self setTitleBarView:self.window.frame.size];
}

-(void)setTitleBarView:(NSSize)size{
    
    //    titleBarView.wantsLayer = YES;
    //    titleBarView.layer.backgroundColor = [NSColor grayColor].CGColor;
    
    [titleBarView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.top.equalTo(@0);
        if (isFullScreen) {
            make.height.equalTo(@22);
        } else {
            make.height.mas_equalTo(50);
        }
    }];
    
    NSButton *closeBtn = [self.window standardWindowButton:NSWindowCloseButton];
    NSButton *zoomBtn = [self.window standardWindowButton:NSWindowZoomButton];
    NSButton *minBtn = [self.window standardWindowButton:NSWindowMiniaturizeButton];
    
    for (NSView *buttonView in @[closeBtn, zoomBtn, minBtn]) {
        [buttonView mas_remakeConstraints:^(MASConstraintMaker *make) {
            if (isFullScreen) {
                make.top.mas_equalTo(3.0);
            } else {
                make.centerY.mas_equalTo(buttonView.superview.mas_centerY);
            }
        }];
    }
}

-(void)initTableView{
    self.listTableView.delegate = self;
    self.listTableView.dataSource = self;
    
    self.listTableView.gridColor = [NSColor magentaColor];
    [self.listTableView reloadData];
}

#pragma mark - NSTableViewDelegate, NSTableViewDataSource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return 5;
}

-(id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    return @{@"title":@"dd.mp4"};
}


-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 28;
}

//-tabl

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSLog(@"ddd");
}

@end
