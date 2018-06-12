//
//  Components.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/12/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "Components.h"

@implementation Components

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"schemas" forKey:@"schemas"];
    return keyPathDict;
}

@end
