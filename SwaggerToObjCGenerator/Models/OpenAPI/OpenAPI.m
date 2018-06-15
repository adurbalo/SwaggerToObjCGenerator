//
//  OpenAPI.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/12/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "OpenAPI.h"
#import "Constants.h"
#import "Info.h"
#import "Path.h"
#import "Components.h"
#import "OAServer.h"
#import "OASchema.h"
#import "DataManager.h"

@implementation OpenAPI

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"openapi" forKey:@"openapi"];
    [keyPathDict setObject:@"info" forKey:@"info"];
    [keyPathDict setObject:@"servers" forKey:@"servers"];
    
    [keyPathDict setObject:@"components" forKey:@"components"];
    [keyPathDict setObject:@"paths" forKey:@"paths"];
    return keyPathDict;
}

+ (NSValueTransformer *)infoJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:Info.class];
}

+ (NSValueTransformer *)serversJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:OAServer.class];
}

+ (NSValueTransformer *)componentsJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:Components.class];
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

-(NSDictionary<NSString *,NSArray<id<GeneratablePath>> *> *)pathsByServiceNames
{
    NSMutableDictionary<NSString*, NSArray<GeneratablePath*> *> *resultDictionary = [NSMutableDictionary new];
    
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
        
        NSMutableArray<id<GeneratablePath>> *pathsForService = [NSMutableArray new];
        
        [filteredKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSArray<Path*> *pathsArray = self.paths[obj];
            if (pathsArray.count > 0) {
                [pathsForService addObjectsFromArray:pathsArray];
            }
        }];
        
        if (pathsForService.count) {
            resultDictionary[serviceName] = [pathsForService copy];
        }
    }];
    
    return [resultDictionary copy];
}

- (NSArray<id<GeneratableDTO>> *)allGeneratableDTO
{
    NSMutableArray<id<GeneratableDTO>> *result = [NSMutableArray new];
    
    [[DataManager sharedManager] addOASchemas:self.components.schemas];
    
    [self.components.schemas enumerateObjectsUsingBlock:^(OASchema * _Nonnull schema, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (schema.enumList) {
            return;
        }
        [result addObject:schema];
    }];
    
    return [result copy];
}

- (NSDictionary<NSString *,NSArray<NSString *> *> *)enumsNamesByOptions
{
    NSMutableDictionary<NSString*, NSArray<NSString*> *> *result = [NSMutableDictionary new];
    
    [self.components.schemas enumerateObjectsUsingBlock:^(OASchema * _Nonnull schema, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (!schema.enumList || !schema.name) {
            return;
        }
        result[[schema.name capitalizeFirstCharacter]] = [schema.enumList copy];
    }];
    
    return [result copy];
}

@end
