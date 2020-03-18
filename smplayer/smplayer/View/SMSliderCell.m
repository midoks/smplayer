//
//  SMSliderCell.m
//  smplayer
//
//  Created by midoks on 2020/3/17.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMSliderCell.h"
@interface SMSliderCell()
{
    CGFloat lineWidth;
    
}
@end

@implementation SMSliderCell


-(void)awakeFromNib{
    lineWidth = 3;
}

-(void)drawBarInside:(NSRect)rect flipped:(BOOL)flipped{
    // [super drawBarInside:rect flipped:flipped];
    rect.size.height = 3.0;
    // Bar radius
    CGFloat barRadius = 1.5;
    
    // Knob position depending on control min/max value and current control value.
    // CGFloat value = ([self doubleValue]  - [self minValue]) / ([self maxValue] - [self minValue]);
    // Final Left Part Width
    //    CGFloat finalWidth = value * ([[self controlView] frame].size.width);
    
    CGFloat pos = [super knobRectFlipped:flipped].origin.x;
    
    // Left Part Rect
    NSRect leftRect = rect;
    leftRect.size.width = pos+3;
    leftRect.origin.x = leftRect.origin.x + lineWidth;
    
    NSRect bgRect = rect;
    bgRect.size.width = bgRect.size.width - (lineWidth + 7);
    bgRect.origin.x = bgRect.origin.x + lineWidth;
    
    // Draw Left Part
    [NSGraphicsContext saveGraphicsState];
    
    NSBezierPath* bg = [NSBezierPath bezierPathWithRoundedRect: bgRect xRadius: barRadius yRadius: barRadius];
    [[NSColor colorWithCalibratedWhite:1 alpha:0.1] setFill];
    [bg fill];
    [NSGraphicsContext restoreGraphicsState];
    
    // Draw Right Part
    [NSGraphicsContext saveGraphicsState];
    NSBezierPath* active = [NSBezierPath bezierPathWithRoundedRect: leftRect xRadius: barRadius yRadius: barRadius];
    [[NSColor colorWithCalibratedWhite:1 alpha:0.3] setFill];
    [active fill];
    [NSGraphicsContext restoreGraphicsState];
}


- (void)drawKnob:(NSRect)knobRect {
    CGFloat knobHeight = 15;
    CGFloat knobWidth = (lineWidth/2);
    CGFloat knobRadius = 1;
    
    NSRect rect = NSMakeRect(knobRect.origin.x + (lineWidth) + 3, knobRect.origin.y + 0.5 * (knobRect.size.height - knobHeight), knobWidth, knobHeight);
    
    [NSGraphicsContext saveGraphicsState];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 1;
    shadow.shadowColor = [NSColor controlShadowColor];
    [shadow setShadowOffset:NSMakeSize(0, 0.5)];
    [shadow set];
    
    NSBezierPath* path = [NSBezierPath bezierPathWithRoundedRect:rect xRadius: knobRadius yRadius: knobRadius];
    [path fill];
    path.lineWidth = (lineWidth/2);
    [[NSColor colorWithCalibratedWhite:1 alpha:1] setStroke];
    [path stroke];
    
    [NSGraphicsContext restoreGraphicsState];
}


-(BOOL)startTrackingAt:(NSPoint)startPoint inView:(NSView *)controlView{
    BOOL result = [super startTrackingAt:startPoint inView:controlView];
    return result;
}

-(void)stopTracking:(NSPoint)lastPoint at:(NSPoint)stopPoint inView:(NSView *)controlView mouseIsUp:(BOOL)flag{
    [super stopTracking:lastPoint at:stopPoint inView:controlView mouseIsUp:flag];
}

@end
