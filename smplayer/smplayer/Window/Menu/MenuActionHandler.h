//
//  MenuActionHandler.h
//  smplayer
//
//  Created by midoks on 2020/3/18.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class Player;

NS_ASSUME_NONNULL_BEGIN

@interface MenuActionHandler : NSResponder

-(id)init:(Player *)player;

// playback
-(void)pauseAction:(NSMenuItem *)sender;
-(void)stepAction:(NSMenuItem *)sender;
-(void)stepFrameAction:(NSMenuItem *)sender;
-(void)jumpToBeginAction:(NSMenuItem *)sender;
-(void)jumpToAction:(NSMenuItem *)sender;
-(void)speedChange:(NSMenuItem *)sender;
-(void)snapshotAction:(NSMenuItem *)sender;
-(void)openScreenshotFolderAction:(NSMenuItem *)sender;

// audio
-(void)volumeChange:(NSMenuItem *)sender;
-(void)volumeMute:(NSMenuItem *)sender;
-(void)audioDelayChange:(NSMenuItem *)sender;
-(void)audioDelayReset:(NSMenuItem *)sender;

// subtitle
-(void)findOnlineSub:(NSMenuItem *)sender;








@end

NS_ASSUME_NONNULL_END
