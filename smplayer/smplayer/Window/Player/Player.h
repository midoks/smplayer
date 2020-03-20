//
//  Player.h
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Carbon/Carbon.h>

#import "SMVideoView.h"
#import "SMPlayerInfo.h"


NS_ASSUME_NONNULL_BEGIN

//NSWindowController
@interface Player : NSWindowController<NSWindowDelegate,SMVideoLayerDelegate>

@property (nonatomic, strong) NSLock* uninitLock;
@property (nonatomic,strong) SMVideoView *videoView;
@property (nonatomic,strong) SMPlayerInfo* info;

+ (id)Instance;
-(void)openVideo:(NSString *)path;
-(void)openVideo:(NSString *)path seek:(double)seek;
-(void)openSelectVideo:(void(^)(void))cmd;
@end

NS_ASSUME_NONNULL_END
