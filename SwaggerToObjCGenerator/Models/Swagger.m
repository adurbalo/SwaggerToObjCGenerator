//
//  Swagger.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 10/31/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "Swagger.h"

@implementation Swagger

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"swagger" forKey:@"swagger"];
    [keyPathDict setObject:@"info" forKey:@"info"];
    [keyPathDict setObject:@"basePath" forKey:@"basePath"];
    [keyPathDict setObject:@"schemes" forKey:@"schemes"];
    [keyPathDict setObject:@"paths" forKey:@"paths"];
    [keyPathDict setObject:@"definitions" forKey:@"definitions"];
    return keyPathDict;
}

+ (NSValueTransformer *)infoJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:Info.class];
}
/*
- (void)setUnprocessedPaths:(NSDictionary<NSString *,NSDictionary *> *)unprocessedPaths
{
    NSMutableDictionary<NSString *,NSArray<Path *> *> *processedPaths = [NSMutableDictionary new];
    
    [unprocessedPaths enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) { //Path Level
        
        NSMutableArray<Path*> *pathsArray = [NSMutableArray new];
       
        [obj enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull methodKey, NSDictionary * _Nonnull methodObj, BOOL * _Nonnull methodStop) { //Method Level
            NSError *error = nil;
            Path *path = [MTLJSONAdapter modelOfClass:[Path class]
                                   fromJSONDictionary:methodObj
                                                error:&error];
            if (error) {
                NSLog(@"Error: %@", error);
            } else {
                path.method = methodKey;
                [pathsArray addObject:path];
            }
        }];
        
        if (pathsArray.count > 0) {
            processedPaths[key] = pathsArray;
        }
    }];
    
    self.paths = processedPaths;
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
*/

+ (NSValueTransformer *)pathsJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSMutableDictionary<NSString*, NSArray<Path*> *> *resultPaths = [NSMutableDictionary new];
        
        [value enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull path, NSDictionary * _Nonnull pathObj, BOOL * _Nonnull stop) {
            
            NSMutableArray<Path*> *definitionsArray = [NSMutableArray new];
            
            [pathObj enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull method, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
                
                NSError *error = nil;
                Path *definition = [MTLJSONAdapter modelOfClass:[Path class]
                                             fromJSONDictionary:obj
                                                          error:&error];
                if (error) {
                    *stop = YES;
                    *success = NO;
                    NSLog(@"Error: %@", error);
                } else {
                    definition.method = method;
                }
                
                if (definition) {
                    [definitionsArray addObject:definition];
                }
            }];
            
            if (definitionsArray.count > 0) {
                resultPaths[path] = definitionsArray;
            }
        }];
        return resultPaths.count > 0?resultPaths:nil;
    }];
}

+ (NSValueTransformer *)definitionsJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSMutableArray<Definition*> *definitionsArray = [NSMutableArray new];
        
        [value enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSError *error = nil;
            Definition *definition = [MTLJSONAdapter modelOfClass:[Definition class]
                                           fromJSONDictionary:obj
                                                        error:&error];
            if (error) {
                *stop = YES;
                *success = NO;
                NSLog(@"Error: %@", error);
            } else {
                definition.name = key;
            }
            
            if (definition) {
                [definitionsArray addObject:definition];
            }
        }];
        return (definitionsArray.count > 0)?definitionsArray:nil;
    }];
}


@end
