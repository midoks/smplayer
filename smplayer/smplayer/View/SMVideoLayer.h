//
//  SMVideoLayer.h
//  smplayer
//
//  Created by midoks on 2020/3/6.
//  Copyright © 2020 midoks. All rights reserved.
//

#include <mpv/client.h>
#include <mpv/render.h>
#include <mpv/render_gl.h>

@import OpenGL.GL;
@import OpenGL.GL3;

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

#import "SMPlayerInfo.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SMSeek) {
    SMSeekNormal = 0,
    SMSeekAbsolute = 1,
    SMSeekRelative = 2
};

@protocol SMVideoLayerDelegate <NSObject>

@optional
-(void)videoStart:(SMVideoTime *)duration;
-(void)videoPos:(SMVideoTime *)pos;

@end

@interface SMVideoLayer : CAOpenGLLayer

@property (weak,nonatomic) id <SMVideoLayerDelegate> videoDelegate;
@property (weak,nonatomic) SMPlayerInfo *info;

@property  dispatch_queue_t queue;

-(void)openVideo:(NSString *)path;
-(void)closeVideo;
-(void)toggleVoice;
-(void)toggleVideo;
-(void)setVoice:(double)value;
-(void)stop;
-(void)start;
-(void)resume;
-(void)quit;
-(void)seek:(NSString *)second option:(SMSeek)option;
-(void)windowScale:(double)scale;

@end

NS_ASSUME_NONNULL_END
