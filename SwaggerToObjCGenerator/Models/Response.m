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
    [keyPathDict setObject:@"content" forKey:@"content"];
    return keyPathDict;
}

+ (NSValueTransformer *)schemaJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:Schema.class];
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

@end
