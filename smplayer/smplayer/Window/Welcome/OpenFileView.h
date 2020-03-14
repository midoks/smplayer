//
//  OpenFileView.h
//  smplayer
//
//  Created by midoks on 2020/3/9.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol OpenFileViewDelegate <NSObject>
@optional
-(void)openFileMouseDown:(NSString *)identifier;
-(void)openFileMouseUp:(NSString *)identifier;
@end

@interface OpenFileView : NSView

@property (nonatomic,strong) id <OpenFileViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
