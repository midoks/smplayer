//
//  SMCommon.h
//  smplayer
//
//  Created by midoks on 2020/2/26.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMCommon : NSObject

+(void)asyncCmd:(void(^)(void))cmd;
@end

NS_ASSUME_NONNULL_END
