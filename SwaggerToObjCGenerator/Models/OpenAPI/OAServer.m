//
//  OAServer.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/13/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "OAServer.h"

@implementation OAServer

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"url" forKey:@"url"];
    [keyPathDict setObject:@"description" forKey:@"serverDescription"];
    return keyPathDict;
}

@end