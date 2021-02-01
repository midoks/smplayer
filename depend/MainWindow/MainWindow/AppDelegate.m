//
//  AppDelegate.m
//  MainWindow
//
//  Created by midoks on 2021/1/21.
//

#import "AppDelegate.h"

#import "Web.h"
#import "MainCore.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[[MainCore Instance] web] showWindow: self];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(IBAction)d:(id)sender{
    NSLog(@"123123");
    [[[MainCore Instance] web] showWindow: self];
}


@end
