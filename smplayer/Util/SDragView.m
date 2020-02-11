//
//  SDragView.m
//  smplayer
//
//  Created by midoks on 2020/2/11.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SDragView.h"

@implementation SDragView


//MARK: - life cycle
- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        //注册文件拖动事件
        [self registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeFileURL, nil]];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    //注册文件拖动事件
    [self registerForDraggedTypes:[NSArray arrayWithObjects:NSPasteboardTypeFileURL, nil]];
}

- (void)dealloc {
    [self unregisterDraggedTypes];
}

//MARK: - private methods
//当文件被拖动到界面触发
- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
//    NSPasteboard *pboard;
//    NSDragOperation sourceDragMask;
//    sourceDragMask = [sender draggingSourceOperationMask];
//    pboard = [sender draggingPasteboard];
//    NSLog(@"draggingEntered:%lu", (unsigned long)sourceDragMask);
//    if ( [[pboard types] containsObject:NSPasteboardTypeFileURL] ) {
//        if (sourceDragMask & NSDragOperationLink) {
//            return NSDragOperationLink;//拖动变成箭头
//        } else if (sourceDragMask & NSDragOperationCopy) {
//            return NSDragOperationCopy;//拖动会变成+号
//        }
//    }
    return NSDragOperationCopy;
}

//当文件在界面中放手
-(BOOL)prepareForDragOperation:(id<NSDraggingInfo>)sender{
    NSPasteboard *zPasteboard = [sender draggingPasteboard];
    // 判断是否是单文件
    if (zPasteboard.pasteboardItems.count <= 1) {
//        NSURL *url = [NSURL URLFromPasteboard:zPasteboard];
        
        NSArray *files = [zPasteboard propertyListForType:NSFilenamesPboardType];
        NSURL *url = [NSURL fileURLWithPath:[files objectAtIndex:0]];
        if (url && self.delegate) {
            [self.delegate receivedFileUrl:url];
        }
    } else {
        //多文件
        NSArray *list = [zPasteboard propertyListForType:NSFilenamesPboardType];
        NSMutableArray *urlList = [NSMutableArray array];
        for (NSString *str in list) {
            NSURL *url = [NSURL fileURLWithPath:str];
            [urlList addObject:url];
        }
        if (urlList.count && self.delegate) {
            [self.delegate receivedFileUrlList:urlList];
        }
    }
    return YES;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:dirtyRect options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |
                           NSTrackingCursorUpdate |
                           NSTrackingActiveWhenFirstResponder |
                           NSTrackingActiveInKeyWindow |
                           NSTrackingActiveInActiveApp |
                           NSTrackingActiveAlways |
                           NSTrackingAssumeInside |
                           NSTrackingInVisibleRect |
                           NSTrackingEnabledDuringMouseDrag
                        owner:self userInfo:nil]];
    
    [self becomeFirstResponder];
}

//鼠标进入追踪区域
-(void)mouseEntered:(NSEvent *)event {
//    NSLog(@"mouseEntered =========");
}

//mouserEntered之后调用
-(void)cursorUpdate:(NSEvent *)event {
//    NSLog(@"cursorUpdate ==========");
    //更改鼠标光标样式
    [[NSCursor pointingHandCursor] set];
}

//鼠标退出追踪区域
-(void)mouseExited:(NSEvent *)event {
//    NSLog(@"mouseExited ========");
}

//鼠标左键按下
-(void)mouseDown:(NSEvent *)event {
    //event.clickCount 不是累计数。双击时调用mouseDown两次，clickCount第一次=1，第二次 = 2.
    if ([event clickCount] > 1) {
        if (self.delegate) {
            [self.delegate mouseDoubleClick:event];
        }
    }
    
//    NSLog(@"mouseDown ==== clickCount: %ld  buttonNumber: %ld",event.clickCount,event.buttonNumber);
    
//    self.layer.backgroundColor = [NSColor redColor].CGColor;
    
    //获取鼠标点击位置坐标：先获取event发生的window中的坐标，在转换成view视图坐标系坐标。
//    NSPoint eventLocation = [event locationInWindow];
//    NSPoint center = [self convertPoint:eventLocation fromView:nil];
    
//    NSLog(@"center: %@",NSStringFromPoint(center));
    
    //判断是否按下了Command键
//    if ([event modifierFlags] & NSEventModifierFlagCommand) {
//        [self setFrameRotation:[self frameRotation] + 90.0];
//        [self setNeedsDisplay:YES];
//        NSLog(@"按下了Command键 ---- ");
//    }
    
}

//鼠标左键起来
-(void)mouseUp:(NSEvent *)event {
//    NSLog(@"mouseUp ======");
//    self.layer.backgroundColor = [NSColor greenColor].CGColor;
}

//鼠标右键按下
- (void)rightMouseDown:(NSEvent *)event {
//    NSLog(@"rightMouseDown =======");
}

//鼠标右键起来
- (void)rightMouseUp:(NSEvent *)event {
//    NSLog(@"rightMouseUp ======= ");
}

//鼠标移动
- (void)mouseMoved:(NSEvent *)event {
//    NSLog(@"mouseMoved ========= ");
}

//鼠标按住左键进行拖拽
- (void)mouseDragged:(NSEvent *)event {
    NSLog(@"mouseDragged ======== ");
}

//鼠标按住右键进行拖拽
- (void)rightMouseDragged:(NSEvent *)event {
//    NSLog(@"rightMouseDragged ======= ");
}

@end

