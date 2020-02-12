//
//  PlayerUIView.m
//  smplayer
//
//  Created by midoks on 2020/2/11.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "PlayerUIView.h"
#import "SToolView.h"
#import "VideoView.h"

@interface PlayerUIView ()

@property (nonatomic, strong) SToolView *tool;
@property (nonatomic, strong) VideoView *video;
@end

@implementation PlayerUIView

- (id)initWithFrame:(NSRect)frame{
    self.frame = frame;
    self = [super initWithFrame:frame];
    if (self) {
        self.wantsLayer = true;
//        self.layer.backgroundColor = [NSColor redColor].CGColor;
        [self initView:frame];
    }
    return self;
}
- (void) initView:(NSRect)frame{
    
    // 视频播放流界面
    self.video = [[VideoView alloc] initWithFrame:self.frame];
    [self addSubview:self.video];
    
    // 控制栏
    self.tool = [[SToolView alloc] initWithFrame:CGRectMake(10, 0, self.frame.size.width-20, 50)];
    [self addSubview:self.tool];
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    self.tool.frame = CGRectMake(10, 0, self.frame.size.width-20, 50);
    self.video.frame = self.frame;
}

@end
