//
//  OAProperty.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/13/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "OAProperty.h"
#import "OASchema.h"

@implementation OAProperty

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"name" forKey:@"name"];
    [keyPathDict setObject:@"type" forKey:@"type"];
    [keyPathDict setObject:@"$ref" forKey:@"ref"];
    [keyPathDict setObject:@"items" forKey:@"items"];
    [keyPathDict setObject:@"enum" forKey:@"enumList"];
    return keyPathDict;
}

+ (NSValueTransformer *)itemsJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:OASchema.class];
}

@end
