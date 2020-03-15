//
//  OpenURL.m
//  smplayer
//
//  Created by midoks on 2020/3/10.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "OpenURL.h"
#import "SMCommon.h"
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
    NSURL *httpUrl = [self getURL];
    NSString *url =  @"";
    if (!httpUrl.scheme){
        url = [NSString stringWithFormat:@"http://%@",httpUrl.absoluteString];
    } else {
        url = httpUrl.absoluteString;
    }
    
    NSString *ext = httpUrl.pathExtension;
    NSMutableArray *list = [SMCommon getSupportPlayFormat];
    
    if ([list containsObject:ext]){
        [[[SMCore Instance] player] showWindow:self];
        [[[SMCore Instance] player] openVideo:url];
        [self.window close];
        [[[SMCore Instance] first] close];
    } else{
        [SMCommon alert:NSLocalizedString(@"alert.invalid_url", nil)];
    }
}

-(NSURL *)getURL{
    NSURL *url = [NSURL URLWithString:_urlTextField.stringValue];
    return url;
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
    
    NSURL *url = [self getURL];
    if (url.scheme){
        [_urlStackView setVisibilityPriority:NSStackViewVisibilityPriorityNotVisible forView:_httpPrexTextField];
        
    } else {
        [_urlStackView setVisibilityPriority:NSStackViewVisibilityPriorityMustHold forView:_httpPrexTextField];
    }
    _openBtn.enabled = YES;
}

@end
