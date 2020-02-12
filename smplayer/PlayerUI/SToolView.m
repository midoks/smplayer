//
//  SToolView.m
//  smplayer
//
//  Created by midoks on 2020/2/11.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SToolView.h"
//@interface SToolView ()
//@property (nonatomic, strong) NSProgressIndicator *progress;
//@property (nonatomic, assign) NSRect frame;
//@end

@implementation SToolView

- (id)initWithFrame:(NSRect)frame{
    self.frame = frame;
    self = [super initWithFrame:frame];
    if (self) {
        progress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, frame.size.height-10, frame.size.width, 10)];
        [self addSubview:progress];
        [self initView:frame];
    }
    return self;
}

- (void) initView:(NSRect)frame{
    
    // 设置颜色
    self.wantsLayer = true;
    self.layer.backgroundColor = [NSColor yellowColor].CGColor;
    
    // 添加进度条
    
    progress.wantsLayer = true;
    progress.minValue = 0.0;
    progress.maxValue = 100.0;
    [progress setDoubleValue:30];
//    [progress.layer setBackgroundColor:[NSColor blueColor].CGColor];
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
     progress.frame = NSMakeRect(0, self.frame.size.height-10, self.frame.size.width, 10);
}

@end
