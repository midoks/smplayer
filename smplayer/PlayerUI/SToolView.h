//
//  SToolView.h
//  smplayer
//
//  Created by midoks on 2020/2/11.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SDragView.h"

NS_ASSUME_NONNULL_BEGIN

@interface SToolView : SDragView {
    NSProgressIndicator *progress;
    NSRect frame;
}

@end

NS_ASSUME_NONNULL_END
