//
//  MenuActionHandler.m
//  smplayer
//
//  Created by midoks on 2020/3/18.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "MenuActionHandler.h"
#import "SMCore.h"

@implementation MenuActionHandler

-(id)initWithCoder:(NSCoder *)coder{
    return [super initWithCoder:coder];
}

#pragma mark - Action
-(void)pauseAction:(NSMenuItem *)sender{
    [[[SMCore Instance] player].videoView.smLayer toggleVideo];
}

@end
