//
//  SMSubtitleShooter.h
//  smplayer
//
//  Created by midoks on 2020/3/26.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SMSubtitleShooter : NSObject

+ (id)Instance;

-(void)request:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
