//
//  main.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 10/31/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Swagger.h"

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        
        NSString *filePath = @"/Users/andreydurbalo/Downloads/tux_m_swagger.json";
//        filePath = @"/Users/andreydurbalo/Documents/Development/Provectus/GIT/SwaggerToObjCGenerator/SwaggerToObjCGenerator/Resources/swagger.json";
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
        
        if (error) {
            NSLog(@"Error: %@", error);
            return 1;
        }
        
    }
    return 0;
}
