//
//  PathParameter.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/1/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "PathParameter.h"

@implementation PathParameter

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"name" forKey:@"name"];
    [keyPathDict setObject:@"in" forKey:@"placedIn"];
    [keyPathDict setObject:@"required" forKey:@"required"];
    [keyPathDict setObject:@"type" forKey:@"type"];
    [keyPathDict setObject:@"format" forKey:@"format"];
    [keyPathDict setObject:@"schema" forKey:@"schema"];
    [keyPathDict setObject:@"schema" forKey:@"oaSchema"];
    [keyPathDict setObject:@"enum" forKey:@"enumList"];
    return keyPathDict;
}

+ (NSValueTransformer *)schemaJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:Schema.class];
}

+ (NSValueTransformer *)requiredJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        BOOL result = [value boolValue];
        return @(result);
    }];
}

#pragma mark - Public

- (Schema *)currentSchema
{
    if (self.schema) {
        return self.schema;
    }
    return self;
}

@end
