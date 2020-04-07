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

@interface SMVideoView : NSView

@property (nonatomic, strong) SMVideoLayer *smLayer;

@end

NS_ASSUME_NONNULL_END
