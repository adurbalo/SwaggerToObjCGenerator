//
//  Swagger.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 10/31/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "Swagger.h"
#import "Constants.h"

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

+ (NSValueTransformer *)pathsJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSMutableDictionary<NSString*, NSArray<Path*> *> *resultPaths = [NSMutableDictionary new];
        
        [value enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull path, NSDictionary * _Nonnull pathObj, BOOL * _Nonnull stop) {
            
            NSMutableArray<Path*> *definitionsArray = [NSMutableArray new];
            
            [pathObj enumerateKeysAndObjectsUsingBlock:^(NSString *  _Nonnull method, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
                
                if ([obj isKindOfClass:[NSNull class]]) {
                    return;
                }
                
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

#pragma mark - Generatable

- (NSDictionary<NSString*, NSArray< id<GeneratablePath> > *> *)pathsByServiceNames
{
    NSMutableDictionary<NSString*, NSArray<Path*> *> *splitedDictionary = [NSMutableDictionary new];
    
    NSMutableSet<NSString *> *servicesNames = [NSMutableSet new];
    
    [[self.paths allKeys] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *components = [[obj componentsSeparatedByString:@"/"] mutableCopy];
        [components removeObject:@""];
        
        if ([components firstObject]) {
            [servicesNames addObject:[components firstObject]];
        }
    }];
    
    [servicesNames enumerateObjectsUsingBlock:^(NSString * _Nonnull serviceName, BOOL * _Nonnull stop) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            
            if (![evaluatedObject hasPrefix:[NSString stringWithFormat:@"/%@", serviceName]]) {
                return NO;
            }
            return YES;
        }];
        NSArray<NSString*> *filteredKeys = [[self.paths allKeys] filteredArrayUsingPredicate:predicate];
        
        NSMutableArray<Path*> *pathsForService = [NSMutableArray new];
        
        [filteredKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSArray<Path*> *pathsArray = self.paths[obj];
            if (pathsArray.count > 0) {
                [pathsForService addObjectsFromArray:pathsArray];
            }
        }];
        
        if (pathsForService.count) {
            splitedDictionary[serviceName] = pathsForService;
        }
    }];
    
    return splitedDictionary;
}

- (NSArray< id<GeneratableDTO> > *)allGeneratableDTO
{
    return [self.definitions copy];
}

- (NSDictionary<NSString *,NSArray<NSString *> *> *)enumsNamesByOptions
{
    NSMutableDictionary<NSString *,NSArray<NSString *> *> *result = [NSMutableDictionary new];
    
    [self.definitions enumerateObjectsUsingBlock:^(Definition * _Nonnull definition, NSUInteger idx, BOOL * _Nonnull stop) {
       
        [definition.properties enumerateObjectsUsingBlock:^(Property * _Nonnull property, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if (property.enumList.count == 0 || !property.name) {
                return;
            }
            result[[property.name capitalizeFirstCharacter]] = property.enumList;
        }];
    }];
    
    return [result copy];
}

@end
