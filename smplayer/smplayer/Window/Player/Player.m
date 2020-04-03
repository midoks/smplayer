//
//  Player.m
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMControlView.h"
#import "SMCommon.h"
#import "SMVideoView.h"
#import "SMCore.h"
#import "MenuListController.h"
#import "MenuActionHandler.h"
#import "MpvHelper.h"
#import "SMPlayerInfo.h"
#import "Player.h"

@interface Player (){
    NSTimer *hideControlTimer;
    NSString *windowTitle;
    NSString *videoSeek;
    BOOL isFileLoaded;
}

@property (nonatomic,assign) BOOL isOnTop;
@property (nonatomic,assign) BOOL isFullScreen;
@property (nonatomic,assign) CGSize minWindowSize;
@property (nonatomic, strong) MenuActionHandler* menuActionHandler;

@property (weak) IBOutlet NSVisualEffectView *titleBarView;

//控制器
@property (weak) IBOutlet SMControlView *controlView;
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

static Player *_instance = nil;
static dispatch_once_t _instance_once;
+ (id)Instance{
    dispatch_once(&_instance_once, ^{
        _instance = [[Player alloc] init];
    });
    return _instance;
}

-(id)init{
    self = [self initWithWindowNibName:@"Player"];
    if (self){
        [self initVar];
        [self regEvent];
    }
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
    
    [self initVideoView];
    [self initControlView];
    
    [self hiddenToolbar];
}

-(void)initVar {
    
    // responder chain | for menu action
    self.window.initialFirstResponder = nil;
    _menuActionHandler = [[MenuActionHandler alloc] init];
    NSResponder *wr = self.window.nextResponder;
    self.window.nextResponder = _menuActionHandler;
    _menuActionHandler.nextResponder = wr;
    

    windowTitle = @"";
    isFileLoaded = NO;
    _isOnTop = NO;
    self.isFullScreen = NO;
    
    self.minWindowSize = NSMakeSize(300, 180);
    
    // view setting
    self.window.movableByWindowBackground = YES;
    self.window.styleMask |= NSWindowStyleMaskFullSizeContentView;
    self.window.appearance =  [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    self.window.titleVisibility = NSWindowTitleVisible;
    self.window.titlebarAppearsTransparent = YES;
    
    _titleBarView.material = NSVisualEffectMaterialDark;
    _titleBarView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    
    _controlView.material = NSVisualEffectMaterialDark;
    _controlView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    
    // save video base info
    _info = [[SMPlayerInfo alloc] init];
}

-(void)regEvent{
    // drag event
    [self.window registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeFileURL, nil]];
    
    [self.window.contentView addTrackingArea:[[NSTrackingArea alloc]
                                              initWithRect:self.window.contentView.bounds
                                              options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |NSTrackingActiveAlways | NSTrackingInVisibleRect
                                              owner:self
                                              userInfo:@{@"obj":@"0"}]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileLoaded) name:SM_NOTIF_FILELOADED object:nil];
}

-(void)initVideoView {
    
    [self.titleBarView setHidden:YES];
    self.titleBarView.layerContentsRedrawPolicy = NSViewLayerContentsRedrawOnSetNeedsDisplay;
    
    _videoView = [[SMVideoView alloc] initWithFrame:self.window.contentView.frame];
    [self.window.contentView addSubview:_videoView positioned:NSWindowBelow relativeTo:nil];
    
    _mpv = [[MpvHelper alloc] init];
    [_mpv initMPV];
    [_mpv initVideoRender];
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
    
    // control view
    [_oscTopView addView:_fragVolumeView inGravity:NSStackViewGravityLeading];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragVolumeView];
    
    [_oscTopView addView:_fragControlView inGravity:NSStackViewGravityCenter];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragControlView];
    
    [self initFragToolbarView];
    [_oscTopView addView:_fragToolbarView inGravity:NSStackViewGravityTrailing];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragToolbarView];
    
    // timeline 
    NSRect newFrame = NSMakeRect(_flagTimelineView.frame.origin.x, _flagTimelineView.frame.origin.y, _timeControlView.frame.size.width, _flagTimelineView.frame.size.height);
    
    _flagTimelineView.frame = newFrame;
    [_timeControlView addSubview:_flagTimelineView];
}

#pragma mark - IBAction

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
                [self->_mpv openVideo:[[panel URL] path]];
            }
        }];
    }];
}

/// 声音关闭开启按钮
- (IBAction)voiceSwitchAction:(id)sender {
    [_mpv toggleVoice];
}

/// 音量改变按钮
- (IBAction)voiceChangeAction:(id)sender {
    [_mpv setVoice:[_flagVolumeSliderView.stringValue doubleValue]];
}

/// 播放暂停按钮
- (IBAction)playAction:(NSButton *)sender {
    if (sender.state == NSControlStateValueOff){
        [_mpv resume];
    } else if (sender.state == NSControlStateValueOn){
        [_mpv stop];
    }
}

- (IBAction)leftButtonAction:(NSButton *)sender {
    if (!isFileLoaded){return;}
    
//    [_videoView.smLayer seek:@"-5" option:SMSeekRelative];
}

- (IBAction)rightButtonAction:(NSButton *)sender {
    if (!isFileLoaded){return;}
    
//    [_videoView.smLayer seek:@"+5" option:SMSeekRelative];
}

- (IBAction)videoChangeAction:(id)sender {
    if (!isFileLoaded){return;}
    
    NSString *sliderValue = [self.flagTimelineSliderView stringValue];
    [_mpv seek:sliderValue option:SMSeekAbsolute];
}


#pragma mark - Private Method Of Drag File
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
    return NSDragOperationCopy;
}

-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender {
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    NSArray *files = [zPasteboard propertyListForType:NSFilenamesPboardType];
    [_mpv openVideo:[files objectAtIndex:0]];
    return YES;
}

#pragma mark - Public Methods
-(void)openVideo:(NSString *)path {
    _info.currentURL = [NSURL fileURLWithPath:path];
    windowTitle = _info.currentURL.lastPathComponent;
    [_mpv openVideo:path];
}

-(void)openVideo:(NSString *)path seek:(double)seek{
    [self openVideo:path];
    videoSeek = [NSString stringWithFormat:@"%f", seek];
}

-(void)openSelectVideo:(void(^)(void))cmd{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setPrompt: @"选择"];
    [panel setCanChooseDirectories:NO];
    [panel setCanChooseFiles:YES];
    [panel setCanCreateDirectories:YES];
    panel.allowsMultipleSelection = YES;
    
    [panel setAllowedFileTypes:[SMCommon getSupportPlayFormat]];
    
    if([panel runModal]){
        [self showWindow:self];
        [self openVideo:[[panel URL] path]];
        cmd();
    }
}

-(void)loadSubtitle:(NSURL *)path{
    
}

-(void)setWindowScale:(double)scale{
    NSRect screenFrame = self.window.screen.visibleFrame;
    NSRect newFrame;
    CGSize newSize = CGSizeMake(_info.width * scale, _info.height * scale);
    
    if (newSize.width>screenFrame.size.width || newSize.height > screenFrame.size.height ){
        NSSize fitToSize = [SMCommon sizeShrink:self.window.frame.size to:screenFrame.size];
        newFrame = [SMCommon resizeCentered:self.window.frame to:fitToSize];
        newFrame = [SMCommon sizeConstrain:newFrame to:screenFrame];
    } else {
        newFrame = [SMCommon resizeCentered:self.window.frame to:newSize];
    }
    [self.window setFrame:newFrame display:YES animate:YES];
}

#pragma mark - menu action
-(void)menuChangeWindowSize:(NSMenuItem *)sender{
    NSInteger size = sender.tag;
    NSRect screenFrame = self.window.screen.visibleFrame;
    NSRect newFrame;
    NSArray *sizeList = @[@0.5,@1,@2];
    CGFloat scaleStep = 25;
    CGFloat telescopic;

    switch (size) {
        case 0:
        case 1:
        case 2:
            [self setWindowScale:[[sizeList objectAtIndex:size] doubleValue]];
            return;
        case 3:
            [self.window center];
            NSSize fitToSize = [SMCommon sizeShrink:self.window.frame.size to:screenFrame.size];
            newFrame = [SMCommon resizeCentered:self.window.frame to:fitToSize];
            break;
        case 10:
        case 11:
            telescopic = size == 10 ? -1 : 1;
            CGFloat newWidth = self.window.frame.size.width + scaleStep * telescopic;
            CGFloat newHeight = newWidth/(self.window.frame.size.width/self.window.frame.size.height);
            CGSize tsSize = [SMCommon satisfyMinSizeWithSameAspectRatio:CGSizeMake(newWidth, newHeight) to:_minWindowSize];
            newFrame = [SMCommon resizeCentered:self.window.frame to:tsSize];
            break;
        default:
            return;
    }
    [self.window setFrame:newFrame display:YES animate:YES];
}

-(void)menuToggleFullScreen:(NSMenuItem *)sender{
    [self.window toggleFullScreen:self];
}

-(void)menuAlwaysOnTop:(NSMenuItem *)sender{
    if(_isFullScreen){return;}
    
    _isOnTop = !_isOnTop;

////        self.window.collectionBehavior = NSWindowCollectionBehaviorFullScreenAuxiliary;
////        self.window.collectionBehavior = NSWindowCollectionBehaviorFullScreenPrimary;
    
    self.window.level = _isOnTop?NSFloatingWindowLevel:NSNormalWindowLevel;
    self.window.collectionBehavior = NSWindowCollectionBehaviorFullScreenPrimary;
}


#pragma mark - NSWindowDelegate
-(NSSize)windowWillResize:(NSWindow *)sender toSize:(NSSize)frameSize
{
    //    NSSize vs = player.videoSize;
    //    CGFloat aspect = vs.width / vs.height;
    //    CGFloat newHeight = frameSize.width / aspect;
    //
    //    [self->player.smLayer windowScale:aspect];
    //    return CGSizeMake(frameSize.width, newHeight);
    
    [_uninitLock lock];
    [_videoView.smLayer display];
    [_uninitLock unlock];
    
    if (frameSize.height <= _minWindowSize.height || frameSize.width <= _minWindowSize.width ){
        CGFloat wAspect = self.window.frame.size.width/self.window.frame.size.height;
        CGFloat mAspect = _minWindowSize.width/_minWindowSize.height;
        if (wAspect > mAspect){
            return NSMakeSize(_minWindowSize.height*wAspect, _minWindowSize.height);
        }
        return NSMakeSize(_minWindowSize.width, _minWindowSize.width/mAspect);
    }
    return frameSize;
}

-(void)windowWillEnterFullScreen:(NSNotification *)notification{
    self.isFullScreen = YES;
    [self.titleBarView setHidden:YES];
    
    self.window.titlebarAppearsTransparent = NO;
    self.window.title = windowTitle;
}

-(void)windowWillExitFullScreen:(NSNotification *)notification{
    self.isFullScreen = NO;
    [self.titleBarView setHidden:NO];
    
    self.window.titlebarAppearsTransparent = YES;
}

-(void)windowWillClose:(NSNotification *)notification{
    [_mpv closeVideo];
}


#pragma mark - Private Method Of Mouse And Toolbar

-(void)hiddenToolbar{
    _controlView.hidden = YES;
    [NSCursor setHiddenUntilMouseMoves:YES];
    
    if (!_isFullScreen){
        self.window.title = @"";
        
        [self.titleBarView setHidden:YES];
        [[self.window standardWindowButton:NSWindowZoomButton] setHidden:YES];
        [[self.window standardWindowButton:NSWindowMiniaturizeButton] setHidden:YES];
        [[self.window standardWindowButton:NSWindowCloseButton] setHidden:YES];
        [[self.window standardWindowButton:NSWindowDocumentIconButton] setHidden:YES];
    }
}

-(void)showToolbar{
    _controlView.hidden = NO;
    
    if (!_isFullScreen){
        self.window.title = windowTitle;
        [self.titleBarView setHidden:NO];
        
        [[self.window standardWindowButton:NSWindowZoomButton] setHidden:NO];
        [[self.window standardWindowButton:NSWindowMiniaturizeButton] setHidden:NO];
        [[self.window standardWindowButton:NSWindowCloseButton] setHidden:NO];
        [[self.window standardWindowButton:NSWindowDocumentIconButton] setHidden:NO];
    }
}

-(void)destroyControlTimer{
    if (hideControlTimer) {
        [hideControlTimer invalidate];
        hideControlTimer = NULL;
    }
}

-(void)createControlTimer{
    hideControlTimer = [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(hiddenToolbar) userInfo:NULL repeats:false];
}

#pragma mark - Mouse Event
-(void)scrollWheel:(NSEvent *)event{
    NSLog(@"asdf:%@",event);
}

-(void)mouseEntered:(NSEvent *)event {
    [self showToolbar];
}

-(void)mouseExited:(NSEvent *)event{
    [self hiddenToolbar];
}

-(void)mouseUp:(NSEvent *)event{
    if ([event clickCount] == 2) {
        [[NSApp mainWindow] toggleFullScreen:event];
    }
}
-(void)mouseMoved:(NSEvent *)event{
    [self showToolbar];
    
    if([SMCommon isMouseEvent:event views:[NSArray arrayWithObjects:self.titleBarView, self.controlView, nil]]){
        [self destroyControlTimer];
    } else {
        [self destroyControlTimer];
        [self createControlTimer];
    }
}

#pragma mark - UI
-(void)videoStart:(SMVideoTime *)duration{
    [self.flagTimelineSliderView setMaxValue:[duration doubleValue]];
    [self.flagTimelineRightView setStringValue:[duration getString]];
}

-(void)videoPos:(SMVideoTime *)pos{
    [self.flagTimelineSliderView setDoubleValue:[pos doubleValue]];
    [self.flagTimelineLeftView setStringValue:[pos getString]];
}

#pragma mark - NSNotificationCenter
-(void)fileLoaded{
    isFileLoaded = YES;
    
//    [self->_videoView.smLayer seek:videoSeek option:SMSeekRelative];
}
@end

