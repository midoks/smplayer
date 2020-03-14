//
//  OpenURL.m
//  smplayer
//
//  Created by midoks on 2020/3/10.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "OpenURL.h"
#import "SMCore.h"

@interface OpenURL ()<NSWindowDelegate,NSTextFieldDelegate,NSControlTextEditingDelegate>

@property (weak) IBOutlet NSStackView *urlStackView;
@property (weak) IBOutlet NSTextField *httpPrexTextField;
@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSButton *openBtn;

@end

@implementation OpenURL

static OpenURL *_instance = nil;
static dispatch_once_t _instance_once;
+ (id)Instance{
    dispatch_once(&_instance_once, ^{
        _instance = [[OpenURL alloc] init];
    });
    return _instance;
}

-(id)init{
    self = [self initWithWindowNibName:@"OpenURL"];
    return self;
}

-(id)initWithWindow:(NSWindow *)window {
    if (self = [super initWithWindow:window]) {
        [self loadWindow];
    }
    return self;
}

-(void)windowDidLoad {
    [super windowDidLoad];
    
    self.window.movableByWindowBackground = YES;
    self.window.titlebarAppearsTransparent = YES;
    self.window.titleVisibility = NSWindowTitleHidden;
    
    
    [_urlStackView setVisibilityPriority:NSStackViewVisibilityPriorityNotVisible forView:_httpPrexTextField];
    
    _urlTextField.delegate = self;
    _openBtn.enabled = NO;
}

- (IBAction)cancelBtnAction:(id)sender {
    [self.window close];
}
- (IBAction)openBtnAction:(id)sender {
    NSString *url = _urlTextField.stringValue;
    
    NSLog(@"dd:%@",url);
    
    NSString *httpUrl = [NSString stringWithFormat:@"http://%@", url];
    
    [[[SMCore Instance] player] showWindow:self];
    [[[SMCore Instance] player] openVideo:httpUrl];
}

#pragma mark - NSControlTextEditingDelegate
-(void)controlTextDidChange:(NSNotification *)obj{
    NSTextView *textView = [obj.userInfo objectForKey:@"NSFieldEditor"];
    NSString *str = [textView textStorage].string;

    if([str isEqualToString:@""]){
        _openBtn.enabled = NO;
        [_urlStackView setVisibilityPriority:NSStackViewVisibilityPriorityNotVisible forView:_httpPrexTextField];
        return;
    }
    
    
    _openBtn.enabled = YES;
    [_urlStackView setVisibilityPriority:NSStackViewVisibilityPriorityMustHold forView:_httpPrexTextField];
}

@end
