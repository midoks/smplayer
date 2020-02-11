//
//  SDragView.h
//  smplayer
//
//  Created by midoks on 2020/2/11.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol SDragViewDelegate <NSObject>
///接收单个文件
- (void)receivedFileUrl:(NSURL *)fileUrl;
///接收到多个文件
- (void)receivedFileUrlList:(NSArray< NSURL *> *)fileUrls;
@end


@interface SDragView : NSView
@property (weak, nonatomic) IBOutlet id<SDragViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
