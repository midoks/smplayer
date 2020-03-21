//
//  MenuActionHandler.h
//  smplayer
//
//  Created by midoks on 2020/3/18.
//  Copyright © 2020 midoks. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface MenuActionHandler : NSResponder

-(void)pauseAction:(NSMenuItem *)sender;
-(void)stepAction:(NSMenuItem *)sender;
@end

NS_ASSUME_NONNULL_END
