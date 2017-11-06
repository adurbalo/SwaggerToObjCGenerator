//
//  Property.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/1/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "Property.h"

@implementation Property

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"name" forKey:@"name"];
    [keyPathDict setObject:@"format" forKey:@"format"];
    [keyPathDict setObject:@"enum" forKey:@"enumList"];
    return keyPathDict;
}

@end
