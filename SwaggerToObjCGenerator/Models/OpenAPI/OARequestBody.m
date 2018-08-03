//
//  OARequestBody.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 7/2/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "OARequestBody.h"

@implementation OARequestBody

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"required" forKey:@"required"];
    [keyPathDict setObject:@"content" forKey:@"content"];
    return keyPathDict;
}

+ (NSValueTransformer *)contentJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSString *contentType = [[value allKeys] firstObject];
        if (!contentType) {
            return nil;
        }
        
        NSError *err = nil;
        OAContent *content = [MTLJSONAdapter modelOfClass:[OAContent class]
                                       fromJSONDictionary:value[contentType]
                                                    error:&err];
        if (err) {
            *success = NO;
            NSLog(@"Error: %@", err);
        } else {
            content.contentType = contentType;
        }
        return content;
    }];
}

+ (NSValueTransformer *)requiredJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSString *value, BOOL *success, NSError *__autoreleasing *error) {
        BOOL result = [value boolValue];
        return @(result);
    }];
}

@end
