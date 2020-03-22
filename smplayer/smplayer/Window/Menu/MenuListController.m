//
//  MenuListController.m
//  smplayer
//
//  Created by midoks on 2020/3/14.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "MenuListController.h"
#import "MenuActionHandler.h"
#import "SMCore.h"

@interface MenuListController()<NSMenuDelegate>

//playback
@property (weak) IBOutlet NSMenu *playback;
@property (weak) IBOutlet NSMenuItem *pause;
@property (weak) IBOutlet NSMenuItem *forward;
@property (weak) IBOutlet NSMenuItem *backward;
@property (weak) IBOutlet NSMenuItem *nextFrame;
@property (weak) IBOutlet NSMenuItem *prevFrame;
@property (weak) IBOutlet NSMenuItem *jumpToBegin;
@property (weak) IBOutlet NSMenuItem *jumpTo;

@end

@implementation MenuListController

-(void)bindMenuItems{
    
    // playback
    _playback.delegate = self;
    _pause.action = @selector(pauseAction:);
    [_pause setKeyEquivalent:@" "];
    
    _forward.action = @selector(stepAction:);
    [_forward setKeyEquivalent:@"→"];

    _nextFrame.action = @selector(stepFrameAction:);
    [_nextFrame setKeyEquivalent:@"."];
    
    _backward.action = @selector(stepAction:);
    [_backward setKeyEquivalent:@"←"];
    
    _prevFrame.action = @selector(stepFrameAction:);
    [_prevFrame setKeyEquivalent:@","];
    
    _jumpToBegin.action = @selector(jumpToBeginAction:);
    _jumpTo.action = @selector(jumpToAction:);
    
    
}

-(void)updatePlaybackMenu{
    
    _pause.title = [[SMCore Instance] player].info.isPause ?
            NSLocalizedString(@"menu.pause",nil):
            NSLocalizedString(@"menu.resume",nil);
    
}

#pragma mark - NSMenuDelegate
-(void)menuWillOpen:(NSMenu *)menu{
    if (menu == _playback){
        [self updatePlaybackMenu];
    }
}

#pragma mark - Control Public Methods

@end
