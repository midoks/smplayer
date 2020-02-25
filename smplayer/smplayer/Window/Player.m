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

@property (weak) IBOutlet NSView *fragVolumeView;
@property (weak) IBOutlet NSView *fragControlView;
@property (strong) IBOutlet NSStackView *fragToolbarView;

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
    //    int mask = NSWindowStyleMaskTitled|NSWindowStyleMaskClosable|
    //    NSWindowStyleMaskMiniaturizable|NSWindowStyleMaskResizable;
    //    [self.window setStyleMask:mask];
    
    [self initVideo];
    
    [_oscTopView addView:_fragVolumeView inGravity:NSStackViewGravityLeading];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragVolumeView];
    
    [_oscTopView addView:_fragControlView inGravity:NSStackViewGravityLeading];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragControlView];
    
    [_oscTopView addView:_fragToolbarView inGravity:NSStackViewGravityLeading];
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragToolbarView];
    
    [self.window.contentView addSubview:_controlView];
    
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
    NSLog(@"ss");
    
    [player stopVoice];
}

@end
