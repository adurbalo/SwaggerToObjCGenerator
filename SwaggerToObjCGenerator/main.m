//
//  main.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 10/31/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsManager.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
    
        NSMutableDictionary<NSString*, NSString*> *arguments = [NSMutableDictionary new];
        for (int i = 0; i < argc; i++) {
            if (i == 0) {
                continue;
            }
            NSString *key = [NSString stringWithUTF8String:argv[i]];
            
            if ([key isEqualToString:HELP_KEY] || [key isEqualToString:SHORT_HELP_KEY]) {
                [[SettingsManager sharedManager] showHelp];
                break;
            }
            
            NSString *value = nil;
            if ([key hasPrefix:@"-"] && ((i+1) < argc)) {
                value = [NSString stringWithUTF8String:argv[i+1]];
                arguments[key]=value;
            }
        }
        
        NSLog(@"Files generation start 🛫");
    
        [[SettingsManager sharedManager] configurateWithArgumentsDictionary:arguments];
       
        id<Generatable> generator = [[SettingsManager sharedManager] generator];
        [generator generateObjC_Classes];
    }
    NSLog(@"Files generation complete 🛬");
    return 0;
}
