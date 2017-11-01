//
//  Response.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/1/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "Response.h"

@implementation Response

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"description" forKey:@"responseDescription"];
    [keyPathDict setObject:@"schema" forKey:@"schema"];
    return keyPathDict;
}

+ (NSValueTransformer *)schemaJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:Schema.class];
}

@end
