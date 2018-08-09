//
//  main.m
//  OpenAPItoObjC_CodeGen
//
//  Created by Andrey Durbalo on 6/27/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "SettingsManager.h"

int main(int argc, const char * argv[]) {
    
    NSMutableDictionary<NSString*, NSString*> *arguments = [NSMutableDictionary new];
    for (int i = 0; i < argc; i++) {
        if (i == 0) {
            continue;
        }
        NSString *key = [NSString stringWithUTF8String:argv[i]];
        NSString *value = nil;
        if ([key hasPrefix:@"-"] && ((i+1) < argc)) {
            value = [NSString stringWithUTF8String:argv[i+1]];
            arguments[key]=value;
        }
    }
    
    [[SettingsManager sharedManager] configurateWithArgumentsDictionary:arguments];
    
    return NSApplicationMain(argc, argv);
}
