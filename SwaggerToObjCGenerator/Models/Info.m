//
//  Info.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 10/31/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "Info.h"

@implementation Info

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"description" forKey:@"infoDescription"];
    [keyPathDict setObject:@"version" forKey:@"version"];
    [keyPathDict setObject:@"title" forKey:@"title"];
    [keyPathDict setObject:@"termsOfService" forKey:@"termsOfService"];
    [keyPathDict setObject:@"contact" forKey:@"contact"];
    [keyPathDict setObject:@"license" forKey:@"license"];
    return keyPathDict;
}

@end

