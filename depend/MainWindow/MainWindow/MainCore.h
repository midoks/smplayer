//
//  MainCore.h
//  MainWindow
//
//  Created by midoks on 2021/2/1.
//

#import <Foundation/Foundation.h>
#import "Web.h"
NS_ASSUME_NONNULL_BEGIN

@interface MainCore : NSObject

+ (id)Instance;

-(Web *)web;
@end

NS_ASSUME_NONNULL_END
