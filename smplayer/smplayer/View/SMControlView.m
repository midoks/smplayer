//
//  ControlView.m
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMCommon.h"
#import "SMControlView.h"

@interface SMControlView()

@property (weak) IBOutlet NSLayoutConstraint *xConstraint;
@property (weak) IBOutlet NSLayoutConstraint *yConstraint;


@property (nonatomic) BOOL isDragging;
@property (nonatomic) CGPoint mousePosRelatedToView;

@end

@implementation SMControlView

-(void)awakeFromNib{

    self.wantsLayer = YES;
    self.layer.cornerRadius = 6;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.isDragging = NO;
    
    self.material = NSVisualEffectMaterialUltraDark;
    self.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
}

-(void)mouseDown:(NSEvent *)event{
    self.isDragging = YES;
    
    _mousePosRelatedToView = NSEvent.mouseLocation;
    _mousePosRelatedToView.x -= self.frame.origin.x;
    _mousePosRelatedToView.y -= self.frame.origin.y;
}

-(void)mouseDragged:(NSEvent *)event{
    
    CGPoint mousePos = _mousePosRelatedToView;
    CGPoint nowLocation = NSEvent.mouseLocation;
    
    CGPoint newOrigin = CGPointMake(nowLocation.x - mousePos.x, nowLocation.y-mousePos.y);
    
    CGFloat xMax = self.window.frame.size.width - self.frame.size.width - 20;
    CGFloat yMax = self.window.frame.size.height - self.frame.size.height - 40;
    
    newOrigin = [SMCommon pointConstrained:newOrigin to:NSMakeRect(10, 10, xMax, yMax)];
    _xConstraint.constant = newOrigin.x - (self.window.frame.size.width - self.frame.size.width) / 2;
    _yConstraint.constant = newOrigin.y;
}

-(void)mouseUp:(NSEvent *)event{
    self.isDragging = NO;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}



@end
