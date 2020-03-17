//
//  Player.h
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SMVideoView.h"


NS_ASSUME_NONNULL_BEGIN

//NSWindowController
@interface Player : NSWindowController<NSWindowDelegate,SMVideoViewDelegate>

@property (strong) SMVideoView *playerView;


+ (id)Instance;
-(void)openVideo:(NSString *)path;
-(void)openVideo:(NSString *)path seek:(double)seek;
-(void)openSelectVideo:(void(^)(void))cmd;
@end

NS_ASSUME_NONNULL_END
