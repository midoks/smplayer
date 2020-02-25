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
    
    // 控制视图
    [_oscTopView addView:_fragVolumeView inGravity:NSStackViewGravityLeading];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragVolumeView];
    
    [_oscTopView addView:_fragControlView inGravity:NSStackViewGravityLeading];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragControlView];
    
    [_oscTopView addView:_fragToolbarView inGravity:NSStackViewGravityLeading];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragToolbarView];
    
    
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
