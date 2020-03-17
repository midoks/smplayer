//
//  MenuListController.m
//  smplayer
//
//  Created by midoks on 2020/3/14.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "MenuListController.h"
#import "SMCore.h"

@interface MenuListController()<NSPortDelegate>

//player
@property (weak) IBOutlet NSMenuItem *pause;

@end

@implementation MenuListController

- (IBAction)pauseAction:(id)sender {
    
    NSLog(@"ll");
    
    [[[SMCore Instance] player].playerView.smLayer toggleVideo];
    
}

@end
