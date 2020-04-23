//
//  RecordScreen.h
//  smplayer
//
//  Created by midoks on 2020/4/12.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RecordScreen : NSWindowController<AVCaptureFileOutputDelegate,AVCaptureFileOutputRecordingDelegate>
+ (id)Instance;
@end

NS_ASSUME_NONNULL_END
