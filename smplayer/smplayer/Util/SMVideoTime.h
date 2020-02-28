//
//  SMVideoTime.h
//  smplayer
//
//  Created by midoks on 2020/2/28.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMVideoTime : NSObject


+ (id)Instance;

-(id)initTime:(double)time;
-(double)doubleValue;
-(int)intValue;
-(NSString *)getString;
@end

NS_ASSUME_NONNULL_END
