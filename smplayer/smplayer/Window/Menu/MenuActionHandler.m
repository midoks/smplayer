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
#import "Player.h"
#import "MenuActionHandler.h"

@interface MenuActionHandler()
@property (nonatomic,strong) Player *player;
@end

@implementation MenuActionHandler

-(id)initWithCoder:(NSCoder *)coder{
    return [super initWithCoder:coder];
}

-(id)init:(Player *)player{
    self = [super init];
    _player = player;
    return self;
}

#pragma mark - Action
-(void)pauseAction:(NSMenuItem *)sender{
    NSLog(@"pauseAction");
    NSLog(@"player:%@", _player);
    [_player.mpv toggleVideo];
}

-(void)stepAction:(NSMenuItem *)sender{
    if (sender.tag == 0){
        [_player.mpv seek:@"+5" option:SMSeekNormal];
    } else if (sender.tag == 1){
        [_player.mpv seek:@"-5" option:SMSeekNormal];
    }
}

-(void)stepFrameAction:(NSMenuItem *)sender{
    if (!_player.info.isPause){
        [_player.mpv stop];
    }
    
    if (sender.tag == 0){
        [_player.mpv frameStep:YES];
    } else if (sender.tag == 1) {
        [_player.mpv frameStep:NO];
    }
}

-(void)jumpToBeginAction:(NSMenuItem *)sender{
    [_player.mpv seek:@"0" option:SMSeekAbsolute];
}

-(void)jumpToAction:(NSMenuItem *)sender{
    [SMCommon quickPromptPanel:@"jump_to" option:SMAlertRunModelStyle callback:^(NSString *inputValue) {
        SMVideoTime *vtime = [[SMVideoTime alloc] initTimeWithString:inputValue];
        [self->_player.mpv seek:[vtime stringValue] option:SMSeekAbsolute];
    }];
}

-(void)speedChange:(NSMenuItem *)sender{
    if (sender.tag == 5) {
        [_player.mpv setSpeed:1];
        return;
    }
    
    double speed =  [sender.representedObject doubleValue];
    [_player.mpv setSpeed:speed];
}

-(void)snapshotAction:(NSMenuItem *)sender{
    [_player.mpv screenshot];
}

-(void)openScreenshotFolderAction:(NSMenuItem *)sender{
    NSString *ssDir = [[Preference Instance] stringForKey:SM_PGG_ScreenShotFolder];
    [[NSWorkspace sharedWorkspace] openURL:[NSURL fileURLWithPath:ssDir]];
}


//audio
-(void)volumeChange:(NSMenuItem *)sender{
    int volumeDelta = [sender.representedObject intValue];
    int newVolume = volumeDelta + _player.info.volume;
    [_player.mpv setVoice:newVolume];
}

-(void)volumeMute:(NSMenuItem *)sender{
    [_player.mpv toggleVoice];
}

-(void)audioDelayChange:(NSMenuItem *)sender{
    double delayDelta = [sender.representedObject doubleValue];
    double newDelay = delayDelta + _player.info.audioDelay;
    _player.info.audioDelay = newDelay;
    [_player.mpv setAudioDelay:newDelay];
}

-(void)audioDelayReset:(NSMenuItem *)sender{
    _player.info.audioDelay = 0;
    [_player.mpv setAudioDelay:0];
}

// subtitle
-(void)findOnlineSub:(NSMenuItem *)sender{
    NSLog(@"findOnlineSub...");
    NSLog(@"%@", _player);
    [[SMSubtitle Instance] get:_player.info.currentURL callback:^(NSUInteger index, NSURL * _Nonnull path) {
        NSLog(@"%lu,%@",index,path);
        
        if (index == 1){
            [self->_player.mpv loadSubtitle:path];
        }
    }];
}

@end
