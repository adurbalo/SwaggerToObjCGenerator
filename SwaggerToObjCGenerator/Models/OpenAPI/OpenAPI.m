//
//  OpenAPI.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/12/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "OpenAPI.h"

@implementation OpenAPI

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"openapi" forKey:@"openapi"];
    [keyPathDict setObject:@"info" forKey:@"info"];
    [keyPathDict setObject:@"paths" forKey:@"paths"];
    return keyPathDict;
}

+ (NSValueTransformer *)infoJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:Info.class];
}

+ (NSValueTransformer *)pathsJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSMutableDictionary<NSString*, NSArray<Path*> *> *resultPaths = [NSMutableDictionary new];
        
        [value enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull path, NSDictionary * _Nonnull pathObj, BOOL * _Nonnull stop) {
            
            NSMutableArray<Path*> *definitionsArray = [NSMutableArray new];
            
            [pathObj enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull method, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
                
                NSError *error = nil;
                Path *pathCandidateObj = [MTLJSONAdapter modelOfClass:[Path class]
                                                   fromJSONDictionary:obj
                                                                error:&error];
                if (error) {
                    *stop = YES;
                    *success = NO;
                    NSLog(@"Error: %@", error);
                } else {
                    pathCandidateObj.method = method;
                    pathCandidateObj.pathString = path;
                }
                
                if (pathCandidateObj) {
                    [definitionsArray addObject:pathCandidateObj];
                }
            }];
            
            if (definitionsArray.count > 0) {
                resultPaths[path] = definitionsArray;
            }
        }];
        return resultPaths.count > 0?resultPaths:nil;
    }];
}

#pragma mark - Generatable

- (void)generateObjC_Classes
{
    NSLog(@"Do nothing currently");
}

@end
