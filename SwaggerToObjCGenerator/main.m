//
//  main.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 10/31/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Swagger.h"
#import "Swagger+CodeGen.h"
#import "SettingsManager.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSString *filePath = @"/Users/andreydurbalo/Downloads/tux_m_swagger.json";

        filePath = @"/Users/andreydurbalo/Downloads/rental_swagger.json";
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        //filePath = [mainBundle pathForResource:@"Resources/swagger" ofType:@"json"];
        
        NSData *data = [NSData dataWithContentsOfFile:filePath];
        NSError *error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:data
                                                                   options:NSJSONReadingAllowFragments
                                                                     error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
            return 1;
        }
        
        Swagger *swagger = [MTLJSONAdapter modelOfClass:[Swagger class]
                                     fromJSONDictionary:dictionary
                                                  error:&error];
        
        [SettingsManager sharedManager].prefix = @"SWG";
        [SettingsManager sharedManager].resourcesPath = [[mainBundle bundlePath] stringByAppendingPathComponent:@"Resources"];
        [SettingsManager sharedManager].destinationPath = @"/Users/andreydurbalo/Desktop/SWG_RESULT_FOLDER/";
        
        if (error) {
            NSLog(@"Error: %@", error);
            return 1;
        } else {
            [swagger generateObjC_Classes];
        }
        
    }
    return 0;
}
