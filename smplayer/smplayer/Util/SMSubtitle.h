//
//  SMSubtitle.h
//  smplayer
//
//  Created by midoks on 2020/3/26.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMSubtitle : NSObject

+ (id)Instance;

-(void)get:(NSURL *)file
  callback:(void(^)(NSUInteger index, NSURL *path))callback;

@end

NS_ASSUME_NONNULL_END
