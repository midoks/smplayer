//
//  SMVideoView.h
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMVideoView : NSView

+ (id)Instance:(NSRect)frame;

-(void)initVideo;
-(void)openVideo:(NSString *)path;
-(void)setVoice:(double)value;
-(void)toggleVoice;
-(void)stop;
-(void)start;
-(void)quit;
@end

NS_ASSUME_NONNULL_END
