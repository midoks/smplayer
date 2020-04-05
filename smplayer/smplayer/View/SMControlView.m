//
//  ControlView.m
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "SMControlView.h"

@interface SMControlView()

@property (weak) IBOutlet NSLayoutConstraint *xConstraint;
@property (weak) IBOutlet NSLayoutConstraint *yConstraint;


@end

@implementation SMControlView

-(void)awakeFromNib{

    self.wantsLayer = YES;
    self.layer.cornerRadius = 6;
    self.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.material = NSVisualEffectMaterialUltraDark;
    self.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
}

-(void)mouseEntered:(NSEvent *)event{
    NSLog(@"ddd");
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}



@end
