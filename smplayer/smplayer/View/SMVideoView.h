//
//  SMVideoView.h
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "SMVideoTime.h"
#import "SMVideoLayer.h"

NS_ASSUME_NONNULL_BEGIN

@protocol SMVideoViewDelegate <NSObject>
@optional

-(void)videoStart:(SMVideoTime *)duration;
-(void)videoPos:(SMVideoTime *)pos;

-(void)hiddenToolbar:(BOOL)yes;

@end


@interface SMVideoView : NSView <SMVideoLayerDelegate>

@property (weak, nonatomic) id <SMVideoViewDelegate> delegate;
@property (nonatomic, strong) SMVideoLayer *smLayer;
@property NSSize videoSize;

+ (id)Instance:(NSRect)frame;

@end

NS_ASSUME_NONNULL_END
