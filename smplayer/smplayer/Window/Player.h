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

@interface Player : NSWindowController
{
    SMVideoView *player;
}

-(void)openVideo:(NSString *)path;
@end

NS_ASSUME_NONNULL_END
