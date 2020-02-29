//
//  SMVideoView.h
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SMVideoTime.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SMVideoViewDelegate <NSObject>
@optional

-(void)videoStart:(SMVideoTime *)duration;
-(void)videoPos:(SMVideoTime *)pos;

@end


@interface SMVideoView : NSOpenGLView

@property (weak, nonatomic) id <SMVideoViewDelegate> delegate;

+ (id)Instance:(NSRect)frame;

-(void)initVideo;
-(void)openVideo:(NSString *)path;
-(void)setVoice:(double)value;
-(void)toggleVoice;
-(void)stop;
-(void)start;
-(void)quit;
-(void)seek:(const char *)second;
-(void)seekWithRelative:(const char *)second;
-(void)seekWithAbsolute:(const char *)second;
@end

NS_ASSUME_NONNULL_END
