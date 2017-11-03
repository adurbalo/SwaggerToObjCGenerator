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

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        /*
        NSString *dirPath = [[NSFileManager defaultManager] currentDirectoryPath];
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        NSString *myFile = [mainBundle pathForResource:@"/Resources/swagger" ofType:@"json"];
        NSData *dataFile = [NSData dataWithContentsOfFile:myFile];
        
        NSMutableString *hContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[@"/Resources" stringByAppendingPathComponent:@"ServiceTemplate.h"]
                                                                                 encoding:NSUTF8StringEncoding
                                                                                    error:nil];
        */
        NSString *filePath = @"/Users/andreydurbalo/Downloads/tux_m_swagger.json";

        filePath = @"/Users/andreydurbalo/Downloads/rental_swagger.json";
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        filePath = [mainBundle pathForResource:@"Resources/swagger" ofType:@"json"];
        
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
        
        swagger.prefix = @"SWG";
        swagger.resourcesPath = [[mainBundle bundlePath] stringByAppendingPathComponent:@"Resources"];
        swagger.destinationPath = @"/Users/andreydurbalo/Desktop/SWG_RESULT_FOLDER/";
        
        
        if (error) {
            NSLog(@"Error: %@", error);
            return 1;
        } else {
            [swagger generateObjC_Classes];
        }
        
    }
    return 0;
}
