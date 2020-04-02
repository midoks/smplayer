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
#import "Preference.h"

@interface MenuListController()<NSMenuDelegate>


//file
@property (weak) IBOutlet NSMenu *file;
@property (weak) IBOutlet NSMenuItem *open;
@property (weak) IBOutlet NSMenuItem *openAlternative;
@property (weak) IBOutlet NSMenuItem *openURL;
@property (weak) IBOutlet NSMenuItem *openURLAlternative;


// playback
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

// video
@property (weak) IBOutlet NSMenu *video;
@property (weak) IBOutlet NSMenuItem *halfSize;
@property (weak) IBOutlet NSMenuItem *normalSize;
@property (weak) IBOutlet NSMenuItem *doubleSize;
@property (weak) IBOutlet NSMenuItem *fitToScreen;
@property (weak) IBOutlet NSMenuItem *biggerSize;
@property (weak) IBOutlet NSMenuItem *smallerSize;
@property (weak) IBOutlet NSMenuItem *fullScreen;
@property (weak) IBOutlet NSMenuItem *alwaysOnTop;

// audio
@property (weak) IBOutlet NSMenu *audio;
@property (weak) IBOutlet NSMenuItem *volumeIndicator;
@property (weak) IBOutlet NSMenuItem *increaseVolume;
@property (weak) IBOutlet NSMenuItem *increaseVolumeSlightly;
@property (weak) IBOutlet NSMenuItem *decreaseVolume;
@property (weak) IBOutlet NSMenuItem *decreaseVolumeSlightly;
@property (weak) IBOutlet NSMenuItem *mute;
@property (weak) IBOutlet NSMenuItem *audioDelayIndicator;
@property (weak) IBOutlet NSMenuItem *increaseAudioDelay;
@property (weak) IBOutlet NSMenuItem *increaseAudioDelaySlightly;
@property (weak) IBOutlet NSMenuItem *decreaseAudioDelay;
@property (weak) IBOutlet NSMenuItem *decreaseAudioDelaySlightly;
@property (weak) IBOutlet NSMenuItem *resetAudioDelay;

// subtitle
@property (weak) IBOutlet NSMenu *subtitle;
@property (weak) IBOutlet NSMenuItem *increaseTextSize;
@property (weak) IBOutlet NSMenuItem *decreaseTextSize;
@property (weak) IBOutlet NSMenuItem *resetTextSize;
@property (weak) IBOutlet NSMenuItem *subFont;
@property (weak) IBOutlet NSMenuItem *findOnlineSub;
@property (weak) IBOutlet NSMenuItem *saveDownloadedSub;



@end

@implementation MenuListController

-(void)bindMenuItems{
    
    //file
    _file.delegate = self;
    
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
        NSMenuItem *item = [i objectAtIndex:0];
        item.action = @selector(speedChange:);
        item.representedObject = [i objectAtIndex:1];
    }
    
    _screenshot.action = @selector(snapshotAction:);
    _goScreenshotDir.action = @selector(openScreenshotFolderAction:);
    
    // video
    _video.delegate = self;
    
    NSArray *videoSize = @[
        @[_halfSize, @0],
        @[_normalSize,@1],
        @[_doubleSize,@2],
        @[_fitToScreen,@3],
        @[_biggerSize,@11],
        @[_smallerSize,@10],
    ];
    
    for (NSArray *i in videoSize) {
        NSMenuItem *item = [i objectAtIndex:0];
        item.tag = [[i objectAtIndex:1] integerValue];
        item.action = @selector(menuChangeWindowSize:);
    }

    _fullScreen.action = @selector(menuToggleFullScreen:);
    _alwaysOnTop.action = @selector(menuAlwaysOnTop:);

    
    // audio
    _audio.delegate = self;
    NSArray *videoVolume = @[
        @[_increaseVolume, @5],
        @[_decreaseVolume,@-5],
        @[_increaseVolumeSlightly,@1],
        @[_decreaseVolumeSlightly,@-1],
    ];
    for (NSArray *i in videoVolume) {
        NSMenuItem *item = [i objectAtIndex:0];
        item.representedObject = [i objectAtIndex:1];
        item.action = @selector(volumeChange:);
    }
    _mute.action = @selector(volumeMute:);
    
    NSArray *videoAudioDelay = @[
        @[_increaseAudioDelay, @0.5],
        @[_increaseAudioDelaySlightly,@0.1],
        @[_decreaseAudioDelay,@-0.5],
        @[_decreaseAudioDelaySlightly,@-0.1],
    ];
    
    for (NSArray *i in videoAudioDelay) {
        NSMenuItem *item = [i objectAtIndex:0];
        item.representedObject = [i objectAtIndex:1];
        item.action = @selector(audioDelayChange:);
    }
    _resetAudioDelay.action = @selector(audioDelayReset:);
    
    //subtitle
    _subtitle.delegate = self;
    _findOnlineSub.action = @selector(findOnlineSub:);
}

#pragma mark - update menu
-(void)updateFileMenu{
    
    if ([[Preference Instance] boolForKey:SM_PGG_AlwaysOpenInNewWindow]){
        _open.hidden = YES;
        _openURL.hidden = YES;
        _openAlternative.hidden = NO;
        _openURLAlternative.hidden = NO;
    } else {
        _open.hidden = NO;
        _openURL.hidden = NO;
        _openAlternative.hidden = YES;
        _openURLAlternative.hidden = YES;
    }
}

-(void)updatePlaybackMenu{
    _pause.title = [[SMCore Instance] player].info.isPause ?
            NSLocalizedString(@"menu.pause",nil):
            NSLocalizedString(@"menu.resume",nil);
    
    _speedIndicator.title = [NSString stringWithFormat:NSLocalizedString(@"menu.speed",nil), [[SMCore Instance] player].info.playSpeed];
}

-(void)updateAudioMenu{
    _volumeIndicator.title = [NSString stringWithFormat:NSLocalizedString(@"menu.volume",nil), (int)[[SMCore Instance] player].info.volume];
    
    _audioDelayIndicator.title = [NSString stringWithFormat:NSLocalizedString(@"menu.audio_delay",nil), [[SMCore Instance] player].info.audioDelay];
}

-(void)updateSubtitleMenu{
    
}

#pragma mark - NSMenuDelegate
-(void)menuWillOpen:(NSMenu *)menu{
    if (menu == _file){
        [self updateFileMenu];
    } else if (menu == _playback){
        [self updatePlaybackMenu];
    } else if (menu == _audio){
        [self updateAudioMenu];
    } else if (menu == _subtitle){
        [self updateSubtitleMenu];
    }
}

#pragma mark - Control Public Methods

@end
