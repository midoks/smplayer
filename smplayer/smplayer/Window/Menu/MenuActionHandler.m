//
//  MenuActionHandler.m
//  smplayer
//
//  Created by midoks on 2020/3/18.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMCore.h"
#import "SMCommon.h"
#import "SMVideoTime.h"
#import "SMSubtitle.h"

#import "MenuActionHandler.h"



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

-(void)stepFrameAction:(NSMenuItem *)sender{
    if (![[SMCore Instance] player].videoView.smLayer.info.isPause){
        [[[SMCore Instance] player].videoView.smLayer stop];
    }
    
    if (sender.tag == 0){
        [[[SMCore Instance] player].videoView.smLayer frameStep:YES];
    } else if (sender.tag == 1) {
        [[[SMCore Instance] player].videoView.smLayer frameStep:NO];
    }
}

-(void)jumpToBeginAction:(NSMenuItem *)sender{
    [[[SMCore Instance] player].videoView.smLayer seek:@"0" option:SMSeekAbsolute];
}

-(void)jumpToAction:(NSMenuItem *)sender{
    [SMCommon quickPromptPanel:@"jump_to" option:SMAlertRunModelStyle callback:^(NSString *inputValue) {
        SMVideoTime *vtime = [[SMVideoTime alloc] initTimeWithString:inputValue];
        [[[SMCore Instance] player].videoView.smLayer seek:[vtime stringValue] option:SMSeekAbsolute];
    }];
}

-(void)speedChange:(NSMenuItem *)sender{
    if (sender.tag == 5) {
        [[[SMCore Instance] player].videoView.smLayer setSpeed:1];
        return;
    }
    
    double speed =  [sender.representedObject doubleValue];
    [[[SMCore Instance] player].videoView.smLayer setSpeed:speed];
}

-(void)snapshotAction:(NSMenuItem *)sender{
    [[[SMCore Instance] player].videoView.smLayer screenshot];
}

-(void)openScreenshotFolderAction:(NSMenuItem *)sender{
    
}


//audio
-(void)volumeChange:(NSMenuItem *)sender{
    int volumeDelta = [sender.representedObject intValue];
    int newVolume = volumeDelta + [[SMCore Instance] player].info.volume;
    [[[SMCore Instance] player].videoView.smLayer setVoice:newVolume];
}

-(void)volumeMute:(NSMenuItem *)sender{
    [[[SMCore Instance] player].videoView.smLayer toggleVoice];
}

-(void)audioDelayChange:(NSMenuItem *)sender{
    double delayDelta = [sender.representedObject doubleValue];
    double newDelay = delayDelta + [[SMCore Instance] player].info.audioDelay;
    [[SMCore Instance] player].info.audioDelay = newDelay;
    [[[SMCore Instance] player].videoView.smLayer setAudioDelay:newDelay];
}

-(void)audioDelayReset:(NSMenuItem *)sender{
    [[SMCore Instance] player].info.audioDelay = 0;
    [[[SMCore Instance] player].videoView.smLayer setAudioDelay:0];
}

// subtitle
-(void)findOnlineSub:(NSMenuItem *)sender{
    NSLog(@"findOnlineSub...");
    [[SMSubtitle Instance] get:[[SMCore Instance] player].info.currentURL];
}

@end
