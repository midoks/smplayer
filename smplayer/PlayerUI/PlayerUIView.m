//
//  PlayerUIView.m
//  smplayer
//
//  Created by midoks on 2020/2/11.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "PlayerUIView.h"
#import "SToolView.h"

@implementation PlayerUIView

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self initView:frame];
    }
    return self;
}
- (void) initView:(NSRect)frame{
    
    // 控制栏
    SToolView *stool = [[SToolView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 50)];
//    stool.wantsLayer = true;
//    stool.layer.backgroundColor = [NSColor blueColor].CGColor;
    [self addSubview:stool];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
//    [self superview].frame;
    NSLog(@"ddddddd----");
    [self initView:[self superview].frame];
    // Drawing code here.
}

@end
