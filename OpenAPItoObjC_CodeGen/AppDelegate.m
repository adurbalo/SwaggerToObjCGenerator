//
//  AppDelegate.m
//  OpenAPItoObjC_CodeGen
//
//  Created by Andrey Durbalo on 6/27/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "AppDelegate.h"
#import "SettingsManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    
    NSArray<NSString *> *arguments = [[NSProcessInfo processInfo] arguments];
    NSMutableDictionary<NSString*, NSString*> *argumentsDictionary = [NSMutableDictionary new];
    
    for (NSInteger idx = 0; idx < arguments.count; idx++) {
        if (idx == 0) {
            continue;
        }
        NSString *key = arguments[idx];
        NSString *value = nil;
        if ([key hasPrefix:@"-"] && ((idx+1) < arguments.count)) {
            value = arguments[idx+1];
            argumentsDictionary[key]=value;
        }
    }
    NSLog(@"argc: %@", argumentsDictionary);
    [[SettingsManager sharedManager] configurateWithArgumentsDictionary:argumentsDictionary];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

- (BOOL)applicationShouldHandleReopen:(NSApplication *)sender hasVisibleWindows:(BOOL)flag
{
    if(!flag)
    {
        for(id const window in sender.windows)
        {
            [window makeKeyAndOrderFront:self];
        }
    }
    return YES;
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return NO;
}

@end
