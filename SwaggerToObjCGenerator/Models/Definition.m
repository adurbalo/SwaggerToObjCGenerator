//
//  Definition.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/1/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "Definition.h"

@implementation Definition

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"type" forKey:@"type"];
    [keyPathDict setObject:@"required" forKey:@"required"];
    [keyPathDict setObject:@"properties" forKey:@"properties"];
    return keyPathDict;
}

+ (NSValueTransformer *)propertiesJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSMutableArray<Property*> *propertiesArray = [NSMutableArray new];
        
        [value enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSError *error = nil;
            Property *response = [MTLJSONAdapter modelOfClass:[Property class]
                                           fromJSONDictionary:obj
                                                        error:&error];
            if (error) {
                *stop = YES;
                *success = NO;
                NSLog(@"Error: %@", error);
            } else {
                response.name = key;
            }
            
            if (response) {
                [propertiesArray addObject:response];
            }
        }];
        return (propertiesArray.count > 0)?propertiesArray:nil;
    }];
}

@end
