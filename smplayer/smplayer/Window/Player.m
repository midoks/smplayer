//
//  Player.m
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//

//AppDelegate.m
//self.player =[[NSWindowController alloc] initWithWindowNibName:@"Player"];
//
//[self.player loadWindow];
//[self.player.window makeKeyWindow];
//[self.player.window makeMainWindow];
//[self.player.window center];


#import "Player.h"
#import "ControlView.h"
#import "SMVideoView.h"

@interface Player ()

//控制器
@property (weak) IBOutlet ControlView *controlView;
@property (weak) IBOutlet NSStackView *oscTopView;
@property (weak) IBOutlet NSView *timeControlView;

@property (weak) IBOutlet NSView *fragVolumeView;
@property (weak) IBOutlet NSView *fragControlView;
@property (strong) IBOutlet NSStackView *fragToolbarView;
@property (strong) IBOutlet NSView *flagTimelineView;

@end

@implementation Player


- (id)initWithWindow:(NSWindow *)window
{
    if (self = [super initWithWindow:window]) {
        [self loadWindow];
    }
    return self;
}

-(void)windowWillLoad{
//    NSLog(@"windowWillLoad:%@", NSStringFromRect(self.window.contentView.frame));
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    NSLog(@"windowDidLoad:%@", NSStringFromRect(self.window.contentView.frame));
    
    // 窗口可以拖拽
    self.window.movableByWindowBackground = YES;
    [self regEvent];
    [self initVideoView];
    
    // NSTouchBarTextListTemplate
    NSButton *list = [[NSButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [list setBezelStyle:NSBezelStyleRegularSquare];
    [list setImage:[NSImage imageNamed:NSImageNameTouchBarAddTemplate]];
    [list setBordered:NO];
    [list setTransparent:YES];
    [_fragToolbarView addView:list inGravity:NSStackViewGravityLeading];
    
    [self initControlView];
    
}

-(void)regEvent{
    // 注册文件拖动事件
    [self.window registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeFileURL, nil]];
}

-(void)initVideoView {
    player = [[SMVideoView alloc] initWithFrame:self.window.contentView.frame];
    //    self.window.contentView = player;
    //    [player setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.window.contentView addSubview:player positioned:NSWindowBelow relativeTo:nil];
}

-(void)initControlView {
    //    _fragToolbarView.frame= CGRectMake(0, 0, 200, 24);
    //    _fragVolumeView.frame = CGRectMake(0, 0, 120, 24);
    // 控制视图
    [_oscTopView addView:_fragVolumeView inGravity:NSStackViewGravityLeading];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragVolumeView];
    
    [_oscTopView addView:_fragControlView inGravity:NSStackViewGravityCenter];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragControlView];
    
    [_oscTopView addView:_fragToolbarView inGravity:NSStackViewGravityTrailing];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragToolbarView];
    
    // 时间线
    NSRect newFrame = NSMakeRect(_flagTimelineView.frame.origin.x, _flagTimelineView.frame.origin.y, _timeControlView.frame.size.width, _flagTimelineView.frame.size.height);
    
    _flagTimelineView.frame =newFrame;
    [_timeControlView addSubview:_flagTimelineView];
}


#pragma mark - 功能

/// 声音关闭开启按钮
- (IBAction)voiceSwitchAction:(id)sender {
    [player toggleVoice];
}

/// 播放暂停按钮
- (IBAction)playAction:(id)sender{
    NSButton *p = (NSButton*)sender;
    if (p.state == NSControlStateValueOff){
        [player stop];
    } else if (p.state == NSControlStateValueOn){
        [player start];
    }
}

#pragma mark - 外部文件拖拽功能
// 当文件被拖动到界面触发
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    return NSDragOperationCopy;
}

//当文件在界面中放手
-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    NSArray *files = [zPasteboard propertyListForType:NSFilenamesPboardType];
    [player openVideo:files[0]];
    return YES;
}

#pragma mark - AppDelegate
-(void)openVideo:(NSString *)path {
    [player openVideo:path];
}

@end
