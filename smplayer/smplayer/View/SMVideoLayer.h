//
//  SMVideoLayer.h
//  smplayer
//
//  Created by midoks on 2020/3/6.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <QuartzCore/QuartzCore.h>

@class Player;
NS_ASSUME_NONNULL_BEGIN

@interface SMVideoLayer : CAOpenGLLayer

-(void)initPlayer:(Player*)player;

-(void)draw;
@end

NS_ASSUME_NONNULL_END
