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
        
        
        [self initView:frame];
    }
    return self;
}

- (void) initView:(NSRect)frame{
    
    // 设置颜色
    self.wantsLayer = true;
    self.layer.backgroundColor = [NSColor grayColor].CGColor;
    self.layer.opacity = 0.6;
    self.layer.cornerRadius = 3;
    
    NSButton *player = [[NSButton alloc] initWithFrame:NSMakeRect(10, 10, 30, 30)];
    [player setButtonType:NSButtonTypeMomentaryChange];
    [player setBezelStyle:NSBezelStyleRegularSquare];
    [player setImage:[NSImage imageNamed:NSImageNameGoForwardTemplate]];
    [player.layer setCornerRadius:10];
    [player setBordered:YES];
    [player.layer setMasksToBounds:YES];
    [self addSubview:player];
    
    //NSImageNameTouchBarPauseTemplate 暂停
    //NSImageNameGoForwardTemplate 开始
    
    
    
    NSTextField *info = [[NSTextField alloc] initWithFrame:NSMakeRect(80, 10, 120, 20)];
//    [info setBackgroundColor:[NSColor redColor]];
    [info setEditable:false];
    [info setBordered:false];
    [info setStringValue:@"01:30:10/02:00:00"];
    [self addSubview:info];
    
    NSButton *speed = [[NSButton alloc] initWithFrame:NSMakeRect(220, 10, 30, 20)];
    [speed setTitle:@"1.0X"];
    [self addSubview:speed];
    
    NSButton *list = [[NSButton alloc] initWithFrame:NSMakeRect(260, 10, 30, 20)];
    [list setTitle:@"列表"];
    [self addSubview:list];
    
    NSButton *voice = [[NSButton alloc] initWithFrame:NSMakeRect(300, 10, 30, 20)];
    [voice setTitle:@"声音"];
    [self addSubview:voice];
    
    NSButton *toggleFullScreen = [[NSButton alloc] initWithFrame:NSMakeRect(340, 10, 70, 20)];
    [toggleFullScreen setTitle:@"放大|缩小"];
    [self addSubview:toggleFullScreen];
    
    progress = [[NSProgressIndicator alloc] initWithFrame:NSMakeRect(0, frame.size.height-10, frame.size.width, 10)];
    // 添加进度条
    progress.wantsLayer = true;
    progress.minValue = 0.0;
    progress.maxValue = 100.0;
    [progress setDoubleValue:30];
    //    [progress.layer setBackgroundColor:[NSColor blueColor].CGColor];
    [self addSubview:progress];
    
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    progress.frame = NSMakeRect(0, self.frame.size.height-10, self.frame.size.width, 10);
}

@end
