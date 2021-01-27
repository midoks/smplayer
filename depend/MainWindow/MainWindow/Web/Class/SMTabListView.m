//
//  SMTabListView.m
//  MainWindow
//
//  Created by midoks on 2021/1/28.
//

#import "Masonry.h"

#import "SMTabListView.h"

@interface SMTabListView()

@property  NSView *bList;

@end

@implementation SMTabListView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizingMask:NSViewWidthSizable|NSViewHeightSizable];
    }
    
    _bList = [[NSView alloc] initWithFrame:NSMakeRect(0, 0, 200, 30)];
    _bList.wantsLayer = TRUE;
//    _bList.layer.backgroundColor = [NSColor redColor].CGColor;
    [self addSubview:_bList];
    
    
    [_bList mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@0);
        make.right.equalTo(@0);
        make.top.equalTo(@0);
        make.height.mas_equalTo(30);
    }];
    
    [self addItem:@"推荐"];
//    [self addItem:@"科幻"];
    return self;
}

-(void)addItem:(NSString *)title{
    NSButton *b = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 80, 30)];
//    b.layer.masksToBounds = YES;
    b.wantsLayer = YES;
    b.layer.cornerRadius = 3.0f;
    b.layer.borderWidth = 0.f;
    b.layer.backgroundColor = [NSColor blueColor].CGColor;
    b.layer.opacity = 0.8;
    b.bezelStyle = NSBezelStyleRegularSquare;
    b.transparent = NO;
    [b setBordered:NO];
    [b setFont:[NSFont systemFontOfSize:14]];
    [b setTitle:title];
    [_bList addSubview:b];
    
}





@end
