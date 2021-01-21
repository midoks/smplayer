//
//  AppDelegate.m
//  MainWindow
//
//  Created by midoks on 2021/1/21.
//

#import "AppDelegate.h"

#import "Web.h"

@interface AppDelegate ()

@property (strong) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    NSLog(@"123123");
    [[Web Instance] showWindow: self.window];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

-(IBAction)d:(id)sender{
    NSLog(@"123123");
    [[Web Instance] showWindow: self.window];
}


@end
