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

#import <Carbon/Carbon.h>


@interface Player (){
    NSTimer *hideControlTimer;
}

//控制器
@property (weak) IBOutlet ControlView *controlView;
@property (weak) IBOutlet NSStackView *oscTopView;
@property (weak) IBOutlet NSView *timeControlView;

@property (weak) IBOutlet NSView *fragVolumeView;
@property (weak) IBOutlet NSSlider *flagVolumeSliderView;

@property (weak) IBOutlet NSView *fragControlView;
@property (weak) IBOutlet NSStackView *fragToolbarView;
@property (weak) IBOutlet NSView *flagTimelineView;

//timeline
@property (weak) IBOutlet NSTextField *flagTimelineLeftView;
@property (weak) IBOutlet NSTextField *flagTimelineRightView;
@property (weak) IBOutlet NSSlider *flagTimelineSliderView;

@end

@implementation Player

-(id)init{
    self = [self initWithWindowNibName:@"Player"];
    return self;
}

-(id)initWithWindow:(NSWindow *)window
{
    if (self = [super initWithWindow:window]) {
        [self loadWindow];
    }
    return self;
}

-(void)windowDidLoad {
    [super windowDidLoad];
    
    // 窗口可以拖拽
    self.window.movableByWindowBackground = YES;
    self.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
    self.window.appearance =  [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    
    [self regEvent];
    
    [self initVideoView];
    [self initControlView];
}

-(void)regEvent{
    // 注册文件拖动事件
    [self.window registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeFileURL, nil]];
    
    [self.window.contentView addTrackingArea:[[NSTrackingArea alloc] initWithRect:self.window.frame options:
                                              NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |
                                              NSTrackingCursorUpdate |
                                              NSTrackingActiveWhenFirstResponder |
                                              NSTrackingActiveInKeyWindow |
                                              NSTrackingActiveInActiveApp |
                                              NSTrackingActiveAlways |
                                              NSTrackingAssumeInside |
                                              NSTrackingInVisibleRect |
                                              NSTrackingEnabledDuringMouseDrag
                                                                            owner:self userInfo:nil]];
}

-(void)initVideoView {
    self->player = [SMVideoView Instance:self.window.contentView.frame];
    //    [self->player initVideo];
    self->player.delegate = self;
    [self.window.contentView addSubview:player positioned:NSWindowBelow relativeTo:nil];
}

-(void)initFragToolbarView{
    // NSImageNameTouchBarTextListTemplate,NSImageNameTouchBarFolderTemplate
    
    //    NSButton *list = [[NSButton alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    //    [list setBezelStyle:NSBezelStyleRegularSquare];
    //    [list setImageScaling:NSImageScaleProportionallyDown];
    //    [list setImage:[NSImage imageNamed:NSImageNameTouchBarTextListTemplate]];
    //    [list setBordered:YES];
    //    [list setTransparent:YES];
    //
    //    [_fragToolbarView addView:list inGravity:NSStackViewGravityTrailing];
    //
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
    
    _flagTimelineView.frame = newFrame;
    [_timeControlView addSubview:_flagTimelineView];
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
                [self->player.smLayer openVideo:[[panel URL] path]];
            }
        }];
    }];
}

/// 声音关闭开启按钮
- (IBAction)voiceSwitchAction:(id)sender {
    [self->player.smLayer toggleVoice];
}

/// 音量改变按钮
- (IBAction)voiceChangeAction:(id)sender {
    [self->player.smLayer setVoice:[_flagVolumeSliderView.stringValue doubleValue]];
}

/// 播放暂停按钮
- (IBAction)playAction:(NSButton *)sender {
    if (sender.state == NSControlStateValueOff){
        [self->player.smLayer start];
    } else if (sender.state == NSControlStateValueOn){
        [self->player.smLayer stop];
    }
}

- (IBAction)leftButtonAction:(NSButton *)sender {
    NSString *s = @"-5";
    [self->player.smLayer seekWithRelative:s.UTF8String];
}

- (IBAction)rightButtonAction:(NSButton *)sender {
    NSString *s = @"+5";
    [self->player.smLayer seekWithRelative:s.UTF8String];
}

- (IBAction)videoChangeAction:(id)sender {
    NSString *sliderValue = [self.flagTimelineSliderView stringValue];
    [self->player.smLayer seekWithAbsolute:sliderValue.UTF8String];
}


#pragma mark - Private Method Of Drag File
// 当文件被拖动到界面触发
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    return NSDragOperationCopy;
}

//当文件在界面中放手
-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    NSArray *files = [zPasteboard propertyListForType:NSFilenamesPboardType];
    [self->player.smLayer openVideo:[files objectAtIndex:0]];
    return YES;
}

#pragma mark - AppDelegate
-(void)openVideo:(NSString *)path {
    [self->player.smLayer openVideo:path];
}

#pragma mark - NSWindowDelegate
//-(NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
//{
////    CGEventSourceRef src = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
////
////    CGEventRef cmdDown = CGEventCreateKeyboardEvent(src, kVK_Shift, true);
////    CGEventRef cmdUp = CGEventCreateKeyboardEvent(src, kVK_Shift, false);
////    CGEventSetFlags(cmdDown, kCGEventFlagMaskCommand);
////    CGEventSetFlags(cmdUp, kCGEventFlagMaskCommand);
////
////    CGEventTapLocation loc = kCGSessionEventTap;
////    CGEventPost(loc, cmdDown);
////    CGEventPost(loc, cmdUp);
////    return frameSize;
//
//    NSSize vs = player.videoSize;
//    CGFloat aspect = vs.width / vs.height;
//    CGFloat newHeight = frameSize.width / aspect;
//
//    [self->player.smLayer windowScale:aspect];
//    return CGSizeMake(frameSize.width, newHeight);
//}

-(void)windowDidChangeScreen:(NSNotification *)notification{
    NSLog(@"%@",notification);
}


#pragma mark - Private Method Of Mouse And Toolbar
-(void)hiddenToolbar{
    _controlView.hidden = YES;
    [[self.window standardWindowButton:NSWindowZoomButton] setHidden:YES];
    [[self.window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
    [[self.window standardWindowButton:NSWindowCloseButton] setHidden:YES];
    [[self.window standardWindowButton:NSWindowDocumentIconButton] setHidden:YES];
    
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = YES;
}

-(void)showToolbar{
    _controlView.hidden = NO;
    [[self.window standardWindowButton:NSWindowZoomButton] setHidden:NO];
    [[self.window standardWindowButton:NSWindowMiniaturizeButton] setHidden:NO];
    [[self.window standardWindowButton:NSWindowCloseButton] setHidden:NO];
    [[self.window standardWindowButton:NSWindowDocumentIconButton] setHidden:NO];
    
    self.window.titleVisibility = NSWindowTitleVisible;
    self.window.titlebarAppearsTransparent = NO;
}

-(void)destroyControlTimer{
    if (hideControlTimer) {
        [hideControlTimer invalidate];
        hideControlTimer = nil;
    }
}

-(void)createControlTimer{
    hideControlTimer = [NSTimer scheduledTimerWithTimeInterval:3 repeats:1 block:^(NSTimer * timer) {
        [self hiddenToolbar];
        [NSCursor setHiddenUntilMouseMoves:YES];
    }];
}

-(void)mouseEntered:(NSEvent *)event {
    [self showToolbar];
}

-(void)mouseExited:(NSEvent *)event{
    [self hiddenToolbar];
    
//    self.window;
}

-(void)mouseUp:(NSEvent *)event{
    if ([event clickCount] == 2) {
        [[NSApp mainWindow] toggleFullScreen:event];
    }
}
-(void)mouseMoved:(NSEvent *)event{
    [self showToolbar];
    
    [self destroyControlTimer];
    [self createControlTimer];
}

#pragma mark - SMVideoViewDelegate
-(void)videoStart:(SMVideoTime *)duration{
    [self.flagTimelineSliderView setMaxValue:[duration doubleValue]];
    [self.flagTimelineRightView setStringValue:[duration getString]];
}

-(void)videoPos:(SMVideoTime *)pos{
    [self.flagTimelineSliderView setDoubleValue:[pos doubleValue]];
    [self.flagTimelineLeftView setStringValue:[pos getString]];
}
@end
