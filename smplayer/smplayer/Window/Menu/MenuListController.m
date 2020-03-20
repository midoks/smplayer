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
@property (weak,nonatomic) IBOutlet NSMenuItem *pause;

@end

@implementation MenuListController

-(void)bindMenuItems{
    
    // playback
    _playback.delegate = self;
    _pause.action = @selector(pauseAction:);
}

-(void)updatePlaybackMenu{
    _pause.title = [[SMCore Instance] player].info.isPause ? @"暂停": @"继续";
}

#pragma mark - NSMenuDelegate
-(void)menuWillOpen:(NSMenu *)menu{
    if (menu == _playback){
        [self updatePlaybackMenu];
    }
}

#pragma mark - Control Public Methods

@end
