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

@interface SMVideoView : NSView <SMVideoLayerDelegate>
@property (nonatomic, strong) SMVideoLayer *smLayer;
@property NSSize videoSize;

+ (id)Instance:(NSRect)frame;

@end

NS_ASSUME_NONNULL_END
