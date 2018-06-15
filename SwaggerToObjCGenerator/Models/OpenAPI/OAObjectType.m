//
//  OAObjectType.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/15/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "OAObjectType.h"

@implementation OAObjectType

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"type" forKey:@"type"];
    [keyPathDict setObject:@"$ref" forKey:@"ref"];
    [keyPathDict setObject:@"items" forKey:@"items"];
    [keyPathDict setObject:@"format" forKey:@"format"];
    [keyPathDict setObject:@"enum" forKey:@"enumList"];
    return keyPathDict;
}

+ (NSValueTransformer *)itemsJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:OAObjectType.class];
}

@end
