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
@optional
// 接收单个文件
- (void)receivedFileUrl:(NSURL *)fileUrl;
// 接收到多个文件
- (void)receivedFileUrlList:(NSArray< NSURL *> *)fileUrls;
// 鼠标双击事件
- (void)mouseDoubleClick:(NSEvent *)event;
@end


@interface SDragView : NSView
@property (weak, nonatomic) IBOutlet id<SDragViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
