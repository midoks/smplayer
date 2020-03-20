//
//  SMVideoView.m
//  smplayer
//
//  Created by midoks on 2020/2/24.
//  Copyright © 2020 midoks. All rights reserved.
//



#import <Cocoa/Cocoa.h>

#import "SMVideoTime.h"
#import "SMVideoView.h"


@interface SMVideoView ()

@end

@implementation SMVideoView


static SMVideoView *_instance = nil;
static dispatch_once_t _instance_once;
+ (id)Instance:(NSRect)frame {
    dispatch_once(&_instance_once, ^{
        _instance = [[SMVideoView alloc] initWithFrame:frame];
    });
    return _instance;
}

- (id)initWithFrame:(NSRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
        _smLayer = [[SMVideoLayer alloc] init];
        _smLayer.videoDelegate = self;
        
        self.layer = _smLayer;
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [self addTrackingArea:[[NSTrackingArea alloc] initWithRect:dirtyRect options:
                           NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved |
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

-(void)openVideo:(NSString *)path{
    [self.smLayer openVideo:path];
}

@end
