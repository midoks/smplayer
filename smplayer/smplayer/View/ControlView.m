//
//  ControlView.m
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "ControlView.h"

@implementation ControlView

-(void)awakeFromNib{
    self.layer.cornerRadius = 6;
    self.wantsLayer = YES;
    self.layer.backgroundColor = [NSColor yellowColor].CGColor;
}

-(void)mouseEntered:(NSEvent *)event{
    NSLog(@"ddd");
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}



@end
