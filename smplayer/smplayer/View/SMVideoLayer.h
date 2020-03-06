//
//  SMVideoLayer.h
//  smplayer
//
//  Created by midoks on 2020/3/6.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SMVideoLayerDelegate <NSObject>
@optional
-(void)videoStart:(SMVideoTime *)duration;
-(void)videoPos:(SMVideoTime *)pos;
@end

@interface SMVideoLayer : CAOpenGLLayer{
//    id <SMVideoLayerDelegate> delegate;
}
@property (weak,atomic,nullable) id <SMVideoLayerDelegate> delegate;


@property  dispatch_queue_t queue;

//-(void)initVideo;
-(void)openVideo:(NSString *)path;
-(void)setVoice:(double)value;
-(void)toggleVoice;
-(void)stop;
-(void)start;
-(void)quit;
-(void)seek:(const char *)second;
-(void)seekWithRelative:(const char *)second;
-(void)seekWithAbsolute:(const char *)second;
-(void)windowScale:(double)scale;
@end

NS_ASSUME_NONNULL_END
