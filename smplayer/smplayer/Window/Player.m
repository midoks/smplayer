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

@interface Player (){
    SMVideoView *player;
}


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

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self initVideo];
    
//    NSTouchBarTextListTemplate
    NSButton *list = [[NSButton alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    [list setBezelStyle:NSBezelStyleRegularSquare];
    [list setImage:[NSImage imageNamed:NSImageNameTouchBarAddTemplate]];
    [list setBordered:NO];
    [list setTransparent:YES];
    [_fragToolbarView addView:list inGravity:NSStackViewGravityLeading];
    
    NSButton *list2 = [[NSButton alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    [list2 setBezelStyle:NSBezelStyleRegularSquare];
    [list2 setImage:[NSImage imageNamed:NSImageNameTouchBarAddTemplate]];
    [list2 setBordered:NO];
    [list2 setTransparent:YES];
    [_fragToolbarView addView:list2 inGravity:NSStackViewGravityCenter];
    
    NSButton *list3 = [[NSButton alloc] initWithFrame:CGRectMake(0, 0, 48, 24)];
    [list3 setBezelStyle:NSBezelStyleRegularSquare];
    [list3 setImage:[NSImage imageNamed:NSImageNameTouchBarAddTemplate]];
    [list3 setBordered:NO];
//    [list3 setsca];
    [list3 setTransparent:YES];
    [_fragToolbarView addView:list3 inGravity:NSStackViewGravityTrailing];
    
//    _fragToolbarView.frame= CGRectMake(0, 0, 200, 24);
//    _fragVolumeView.frame = CGRectMake(0, 0, 120, 24);
    // 控制视图
    [_oscTopView addView:_fragVolumeView inGravity:NSStackViewGravityLeading];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragVolumeView];
    
    [_oscTopView addView:_fragControlView inGravity:NSStackViewGravityCenter];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragControlView];
    
    [_oscTopView addView:_fragToolbarView inGravity:NSStackViewGravityTrailing];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragToolbarView];
    
//    _fragVolumeView.hidden = YES;
    
    // 时间线
    NSRect newFrame = NSMakeRect(_flagTimelineView.frame.origin.x, _flagTimelineView.frame.origin.y, _timeControlView.frame.size.width, _flagTimelineView.frame.size.height);
    
    _flagTimelineView.frame =newFrame;
    [_timeControlView addSubview:_flagTimelineView];
    
}

-(void)initVideo{
    
    NSLog(@"%@", NSStringFromRect(self.window.contentView.frame) );
    player = [[SMVideoView alloc] initWithFrame:self.window.contentView.frame];
    //    self.window.contentView = player;
    //    [player setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.window.contentView addSubview:player positioned:NSWindowBelow relativeTo:nil];
    
    
    //    for (NSLayoutConstraint *v in self.window.contentView.constraints) {
    //        NSLog(@"%@",v);
    //    }
    
}

- (IBAction)VoiceSwitch:(id)sender {    
    [player stopVoice];
}

@end
