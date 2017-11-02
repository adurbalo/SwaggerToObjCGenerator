//
//  Schema.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/1/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "Schema.h"

@implementation Schema

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"type" forKey:@"type"];
    [keyPathDict setObject:@"items" forKey:@"itemsType"];
    [keyPathDict setObject:@"$ref" forKey:@"reference"];
    return keyPathDict;
}

+ (NSValueTransformer *)itemsTypeJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSString *itemType = value[@"type"];
        if (!itemType) {
            itemType = value[@"$ref"];
        }
        return itemType;
    }];
}

#pragma mark - Internal

- (NSString*)toObjCClassNameFromType:(NSString*)type
{
    NSString *objCNameClass = nil;
    
    if ([type isEqualToString:@"string"]) {
        objCNameClass = @"NSString";
    } else if ([type isEqualToString:@"array"]) {
        objCNameClass = @"NSArray";
    } else {
//        NSLog(@"Unimplemented fro type: %@", type);
        objCNameClass = type;
    }
    return objCNameClass;
}

#pragma mark - Public

- (NSString *)objC_mainTypeName
{
    if (self.reference) {
        return [self.reference lastPathComponent];
    }
    return [self toObjCClassNameFromType:self.type];
}

- (NSString *)objC_genericTypeName
{
    if (!self.itemsType) {
        return nil;
    }
    return [self toObjCClassNameFromType:[self.itemsType lastPathComponent]];
}

-(NSString *)objC_fullTypeName
{
    if ([[self objC_mainTypeName] isEqualToString:@"id"]) {
        return [self objC_mainTypeName];
    }
    NSString *generic = [self objC_genericTypeName];
    if (generic) {
        return [NSString stringWithFormat:@"%@<%@ *> *", [self objC_mainTypeName], generic];
    }
    return [NSString stringWithFormat:@"%@ *", [self objC_mainTypeName]];
}

- (NSArray<NSString *> *)allTypes
{
    NSMutableArray *allTypes = [NSMutableArray new];
    if ([self objC_mainTypeName]) {
        [allTypes addObject:[self objC_mainTypeName]];
    }
    if ([self objC_genericTypeName]) {
        [allTypes addObject:[self objC_genericTypeName]];
    }
    return allTypes;
}

@end
