//
//  Welcome.m
//  smplayer
//
//  Created by midoks on 2020/3/7.
//  Copyright © 2020 midoks. All rights reserved.
//

#import "Welcome.h"
#import "OpenFileView.h"

@interface Welcome () <NSTableViewDelegate,NSTableViewDataSource>

@property (weak) IBOutlet NSView *mainView;

@property (weak) IBOutlet NSTextField *version;

@property (weak) IBOutlet NSVisualEffectView *visualEffectView;
@property (weak) IBOutlet OpenFileView *lastFileView;
@property (weak) IBOutlet NSImageView *lastFileIcon;
@property (weak) IBOutlet NSTextField *lastFileNameLabel;
@property (weak) IBOutlet NSTextField *lastFilePosLabel;

@property (weak) IBOutlet NSTableView *recentFilesTableView;

@end

@implementation Welcome


-(id)init{
    self = [self initWithWindowNibName:@"Welcome"];
    return self;
}


static Welcome *_instance = nil;
static dispatch_once_t _instance_once;
+ (id)Instance{
    dispatch_once(&_instance_once, ^{
        _instance = [[Welcome alloc] init];
    });
    return _instance;
}

-(id)initWithWindow:(NSWindow *)window
{
    if (self = [super initWithWindow:window]) {
        [self loadWindow];
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    self.window.movableByWindowBackground = YES;
    self.window.titleVisibility = NSWindowTitleHidden;
    self.window.titlebarAppearsTransparent = YES;
    
    self.window.appearance =  [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    self.mainView.wantsLayer = YES;
    
    self.mainView.layer.backgroundColor = CGColorCreateGenericGray(0.5, 0.1);
    self.visualEffectView.appearance = [NSAppearance appearanceNamed:NSAppearanceNameVibrantDark];
    self.lastFileIcon.image = [NSImage imageNamed:@"history"];
    
    [self.lastFileNameLabel setStringValue:@"demo.mp4"];
    [self.lastFilePosLabel setStringValue:@"10:20"];
    
    
    NSString *version = [[NSBundle mainBundle]objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [self.version setStringValue:version];
    
    [self initRecentTableView];
    
}

-(void)initRecentTableView{
//    self.recentFilesTableView.backgroundColor = [NSColor orangeColor];
//    self.recentFilesTableView.usesAlternatingRowBackgroundColors = YES;
    self.recentFilesTableView.delegate = self;
    self.recentFilesTableView.dataSource = self;
    
//    [self.recentFilesTableView setdraw]
    
    [self.recentFilesTableView reloadData];
    
}


#pragma mark - NSTableViewDelegate, NSTableViewDataSource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return 3;
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row{
    
    NSString *strIdt = @"viewForTableColumn_show";
    NSTableCellView *cell = [tableView makeViewWithIdentifier:strIdt owner:self];
    if (!cell) {
        cell = [[NSTableCellView alloc] init];
        cell.identifier = strIdt;
    }
    
//    cell.imageView.image = [NSImage imageNamed:@"history"];
    cell.textField.stringValue = @"234234";
    [cell.textField setTextColor:[NSColor whiteColor]];
    cell.wantsLayer = YES;
//    cell.layer.backgroundColor = [NSColor whiteColor].CGColor;
    return cell;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 20;
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification{
    NSLog(@"ddd");
}


@end
