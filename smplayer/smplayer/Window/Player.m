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

@interface Player ()


//控制器
@property (weak) IBOutlet ControlView *controlView;
@property (weak) IBOutlet NSStackView *oscTopView;

@property (weak) IBOutlet NSView * fragVolumeView;

@end

@implementation Player


- (id)initWithWindow:(NSWindow *)window
{
    if (self = [super initWithWindow:window]) {
        [self loadWindow];
    }
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(windowWillClose:) name:NSWindowWillCloseNotification object:self.window];
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    
    NSLog(@"ddddddddddddddddd----------------start!");
    
//    [NSStackView r];
//    [_oscTopView removeView:_oscTopView.views];
//    [_fragVolumeView removeFromSuperview];
    [_oscTopView addView:_fragVolumeView inGravity:NSStackViewGravityLeading];
    _oscTopView.wantsLayer = YES;
    _oscTopView.layer.backgroundColor = [NSColor blueColor].CGColor;
    [_oscTopView setVisibilityPriority:NSStackViewVisibilityPriorityDetachOnlyIfNecessary forView:_fragVolumeView];
    
//    _oscTopView.hidden = NO;
//    _oscTopView.alphaValue = 1;
    
//    NSLog(@"%@", _fragVolumeView);
//    NSLog(@"%@", _fragVolumeView.subviews);
//    _fragVolumeView.subviews[0].hidden = NO;
//    _fragVolumeView.subviews[0].alphaValue = 1;
    
//    _fragVolumeView.hidden = NO;
//    _fragVolumeView.alphaValue = 1;
    
//    _controlView.frame = NSMakeRect(0, 0, 400, 100);
//    _controlView.wantsLayer = YES;
//    _controlView.layer.backgroundColor=[NSColor redColor].CGColor;
//
//    [self.window.contentView addSubview:_controlView];
    
    
    
    
}

@end
