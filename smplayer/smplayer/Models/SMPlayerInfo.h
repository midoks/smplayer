//
//  SMPlayerInfo.h
//  smplayer
//
//  Created by midoks on 2020/3/20.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMPlayerInfo : NSObject

@property  BOOL isPause;
@property  double playSpeed;
@property  double audioDelay;

@property double width;
@property double height;
@property double volume;

@end

NS_ASSUME_NONNULL_END
