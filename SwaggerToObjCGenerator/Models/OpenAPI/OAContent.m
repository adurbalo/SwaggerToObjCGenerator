//
//  OAContent.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/15/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "OAContent.h"
#import "OASchema.h"

@implementation OAContent

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"schema" forKey:@"schema"];
    return keyPathDict;
}

+ (NSValueTransformer *)schemaJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:OASchema.class];
}

@end
