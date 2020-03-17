//
//  MenuListController.m
//  smplayer
//
//  Created by midoks on 2020/3/14.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "MenuListController.h"
#import "SMCore.h"

@interface MenuListController()<NSMenuDelegate>

//playback
@property (weak) IBOutlet NSMenuItem *pause;

@end

@implementation MenuListController

-(void)bindMenuItems{
    
    NSLog(@"bindMenuItems ready");
    
    [self.pause setAction:@selector(pauseAction:)];
}

#pragma mark - Action
-(void)pauseAction:(NSMenuItem *)sender {
    [[[SMCore Instance] player].playerView.smLayer toggleVideo];
}



#pragma mark - NSMenuDelegate

-(void)menuWillOpen:(NSMenu *)menu{
    NSLog(@"menuWillOpen");
}

@end
