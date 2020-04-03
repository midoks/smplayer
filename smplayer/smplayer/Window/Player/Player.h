//
//  Player.h
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>
#import "SMPlayerInfo.h"
#import "MpvHelper.h"

#import "SMVideoView.h"



NS_ASSUME_NONNULL_BEGIN

//NSWindowController
@interface Player : NSWindowController<NSWindowDelegate>

@property (nonatomic, strong) MpvHelper *mpv;
@property (nonatomic, strong) NSLock* uninitLock;
@property (nonatomic,strong) SMVideoView *videoView;
@property (nonatomic,strong) SMPlayerInfo* info;

+ (id)Instance;
-(void)openVideo:(NSString *)path;
-(void)openVideo:(NSString *)path seek:(double)seek;
-(void)openSelectVideo:(void(^)(void))cmd;

-(void)videoStart:(SMVideoTime *)duration;
-(void)videoPos:(SMVideoTime *)pos;

// menu
-(void)menuChangeWindowSize:(NSMenuItem *)sender;
-(void)menuToggleFullScreen:(NSMenuItem *)sender;
-(void)menuAlwaysOnTop:(NSMenuItem *)sender;
@end

NS_ASSUME_NONNULL_END
