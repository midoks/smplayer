//
//  MpvHelper.h
//  smplayer
//
//  Created by midoks on 2020/3/21.
//  Copyright © 2020 midoks. All rights reserved.
//

#include <mpv/client.h>
#include <mpv/render.h>
#include <mpv/render_gl.h>

@import OpenGL.GL;
@import OpenGL.GL3;

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@class Player;

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SMSeek) {
    SMSeekNormal = 0,
    SMSeekAbsolute = 1,
    SMSeekRelative = 2
};


typedef NS_ENUM(NSUInteger, SMUserOption) {
    SMInt,
    SMBool,
    SMFloat,
    SMString,
    SMColor,
    SMOther,
};



@interface MpvHelper : NSObject

@property mpv_render_context *context;


-(id)init:(Player*)player;

-(void)renderMPV;
-(BOOL)shouldRenderUpdateFrame;
-(id)getNode:(NSString *)name;

#pragma mark - mpv cmd -
-(int)getInt:(NSString *)name;
-(void)setInt:(NSString *)name value:(NSInteger)value;
-(double)getDouble:(NSString *)name;
-(void)setDouble:(NSString *)name value:(double)value;
-(void)setString:(NSString *)name value:(NSString *)value;
-(BOOL)getFlag:(NSString *)name;
-(void)setFlag:(NSString *)name flag:(BOOL)flag;

#pragma mark - public method -
-(void)openVideo:(NSString *)path;
-(void)closeVideo;
-(void)start;
-(void)stop;
-(void)setAudioDelay:(double)delay;
-(void)setVoice:(double)value;
-(void)setSpeed:(double)speed;
-(void)toggleVoice;
-(void)toggleVideo;
-(void)seek:(NSString *)second option:(SMSeek)option;
-(void)frameStep:(BOOL)backwards;
-(void)screenshot;
-(void)loadSubtitle:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
