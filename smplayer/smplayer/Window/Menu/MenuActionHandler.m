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

-(void)stepAction:(NSMenuItem *)sender{
    
    if (sender.tag == 0){
        [[[SMCore Instance] player].videoView.smLayer seek:@"+5" option:SMSeekNormal];
    } else if (sender.tag == 1){
        [[[SMCore Instance] player].videoView.smLayer seek:@"-5" option:SMSeekNormal];
    }
}


@end
