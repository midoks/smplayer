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

#import "SMCommon.h"
#import "SMVideoView.h"


@interface Player ()

//控制器
@property (weak) IBOutlet ControlView *controlView;
@property (weak) IBOutlet NSStackView *oscTopView;
@property (weak) IBOutlet NSView *timeControlView;

@property (weak) IBOutlet NSView *fragVolumeView;
@property (weak) IBOutlet NSSlider *flagVolumeSliderView;

@property (weak) IBOutlet NSView *fragControlView;
@property (weak) IBOutlet NSStackView *fragToolbarView;
@property (weak) IBOutlet NSView *flagTimelineView;


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
    

    [self initControlView];
}

-(void)regEvent{
    // 注册文件拖动事件
    [self.window registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeFileURL, nil]];
}

-(void)initVideoView {
    player = [SMVideoView Instance:self.window.contentView.frame];
    [player initVideo];
    [self.window.contentView addSubview:player positioned:NSWindowBelow relativeTo:nil];
}

-(void)initFragToolbarView{
    // NSImageNameTouchBarTextListTemplate,NSImageNameTouchBarFolderTemplate
    NSButton *list = [[NSButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [list setBezelStyle:NSBezelStyleRegularSquare];
    [list setImageScaling:NSImageScaleProportionallyDown];
    [list setImage:[NSImage imageNamed:NSImageNameTouchBarTextListTemplate]];
    [list setBordered:YES];
    [list setTransparent:YES];
    
    [_fragToolbarView addView:list inGravity:NSStackViewGravityTrailing];
    
    NSButton *dir = [[NSButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [dir setBezelStyle:NSBezelStyleRegularSquare];
    [dir setImage:[NSImage imageNamed:NSImageNameTouchBarFolderTemplate]];
    [dir setImageScaling:NSImageScaleProportionallyDown];
    [dir setBordered:YES];
    [dir setTransparent:YES];
    
    [dir setAction:@selector(selectedDIr:)];
    [_fragToolbarView addView:dir inGravity:NSStackViewGravityLeading];
    
}

-(void)initControlView {
    
    // 控制视图
    [_oscTopView addView:_fragVolumeView inGravity:NSStackViewGravityLeading];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragVolumeView];
    
    [_oscTopView addView:_fragControlView inGravity:NSStackViewGravityCenter];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragControlView];
    
    [self initFragToolbarView];
    [_oscTopView addView:_fragToolbarView inGravity:NSStackViewGravityTrailing];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragToolbarView];
    
    // 时间线
    NSRect newFrame = NSMakeRect(_flagTimelineView.frame.origin.x, _flagTimelineView.frame.origin.y, _timeControlView.frame.size.width, _flagTimelineView.frame.size.height);
    
    _flagTimelineView.frame =newFrame;
    [_timeControlView addSubview:_flagTimelineView];
}

-(void)initMenu{
    NSMenu *m = [[NSMenu alloc] initWithTitle:@"AMainMenu"];
    NSMenuItem *item = [m addItemWithTitle:@"Apple" action:nil keyEquivalent:@""];
    NSMenu *sm = [[NSMenu alloc] initWithTitle:@"Apple"];
    [m setSubmenu:sm forItem:item];
    [sm addItemWithTitle: @"mpv_cmd('stop')" action:@selector(stop) keyEquivalent:@"s"];
    [sm addItemWithTitle: @"mpv_cmd('quit')" action:@selector(quit) keyEquivalent:@"r"];
    [sm addItemWithTitle: @"quit" action:@selector(terminate:) keyEquivalent:@"q"];
    [NSApp setMenu:m];
    [NSApp activateIgnoringOtherApps:YES];
}

#pragma mark - 功能

/// 文件选择
-(IBAction)selectedDIr:(id)sender
{
    [SMCommon asyncCmd:^{
        NSOpenPanel *panel = [NSOpenPanel openPanel];
        [panel setPrompt: @"选择"];
        [panel setCanChooseDirectories:NO];    //不可以打开目录
        [panel setCanChooseFiles:YES];         //能选择文件
        [panel setAllowedFileTypes:[NSArray arrayWithObject:@"mp4"]];
        
        [panel beginWithCompletionHandler:^(NSModalResponse result) {
            if (result){
                [self->player openVideo:[[panel URL] path]];
            }
        }];
    }];
}

/// 声音关闭开启按钮
- (IBAction)voiceSwitchAction:(id)sender {
    [player toggleVoice];
}

/// 音量改变按钮
- (IBAction)voiceChangeAction:(id)sender {
    [player setVoice:[_flagVolumeSliderView.stringValue doubleValue]];
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
