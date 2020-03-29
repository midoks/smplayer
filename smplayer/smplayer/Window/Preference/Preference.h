//
//  Preference.h
//  smplayer
//
//  Created by midoks on 2020/3/9.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PreferenceGeneral.h"
#import "PreferenceNetwork.h"

NS_ASSUME_NONNULL_BEGIN

@interface Preference : NSWindowController

+ (id)Instance;
@end

NS_ASSUME_NONNULL_END
