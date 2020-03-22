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
@property (weak) IBOutlet NSMenuItem *speedIndicator;
@property (weak) IBOutlet NSMenuItem *speedUp;
@property (weak) IBOutlet NSMenuItem *speedUpSlightly;
@property (weak) IBOutlet NSMenuItem *speedDown;
@property (weak) IBOutlet NSMenuItem *speedDownSlightly;
@property (weak) IBOutlet NSMenuItem *speedReset;

@property (weak) IBOutlet NSMenuItem *screenshot;
@property (weak) IBOutlet NSMenuItem *goScreenshotDir;




@end

@implementation MenuListController

-(void)bindMenuItems{
    
    // playback
    _playback.delegate = self;
    _pause.action = @selector(pauseAction:);
    [_pause setKeyEquivalent:@" "];
    
    ///speed
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
    
    ///speed
    NSArray *speedList = @[
                            @[_speedUp, @"2.0"],
                            @[_speedUpSlightly, @"1.1"],
                            @[_speedDown,@"0.5"],
                            @[_speedDownSlightly,@"0.9"],
                            @[_speedReset,@"1.0"]
                        ];
    for (NSArray *i in speedList) {
        NSMenuItem *speed = [i objectAtIndex:0];
        speed.action = @selector(speedChange:);
        speed.representedObject = [i objectAtIndex:1];
    }
    
    _screenshot.action = @selector(snapshotAction:);
    _goScreenshotDir.action = @selector(openScreenshotFolderAction:);

}

-(void)updatePlaybackMenu{
    
    _pause.title = [[SMCore Instance] player].info.isPause ?
            NSLocalizedString(@"menu.pause",nil):
            NSLocalizedString(@"menu.resume",nil);
    
    _speedIndicator.title = [NSString stringWithFormat:NSLocalizedString(@"menu.speed",nil), [[SMCore Instance] player].info.playSpeed];
}

#pragma mark - NSMenuDelegate
-(void)menuWillOpen:(NSMenu *)menu{
    if (menu == _playback){
        [self updatePlaybackMenu];
    }
}

#pragma mark - Control Public Methods

@end
