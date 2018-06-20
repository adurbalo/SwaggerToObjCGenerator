//
//  NSString+Helper.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/3/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

- (NSString *)capitalizeFirstCharacter
{
    if (self.length <= 1) {
        return [self uppercaseString];
    }
    NSString *capitalizedString = [NSString stringWithFormat:@"%@%@", [[self substringToIndex:1] uppercaseString], [self substringFromIndex:1]];
    return capitalizedString;
}

- (NSString *)lowercaseFirstCharacter
{
    if (self.length <= 1) {
        return [self lowercaseString];
    }
    NSString *lowercaseString = [NSString stringWithFormat:@"%@%@", [[self substringToIndex:1] lowercaseString], [self substringFromIndex:1]];
    return lowercaseString;
}

- (NSString *)documentationStyleString
{
    if (self.length == 0) {
        return self;
    }
    NSString *formated = [self stringByReplacingOccurrencesOfString:@"\n" withString:@"\n * "];
    formated = [self stringByReplacingOccurrencesOfString:@". " withString:@".\n * "];
    NSString *result = [NSString stringWithFormat:@"/**\n * %@\n */\n", formated];
    return result;
}

- (NSString *)camelCaseStyleSting
{
    if (self.length == 0) {
        return @"";
    }
    NSArray<NSString *> *descriptionComponents = [self componentsSeparatedByCharactersInSet:[[NSCharacterSet letterCharacterSet] invertedSet]];
    
    __block NSString *camelStyle = @"";
    [descriptionComponents enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            camelStyle = [obj lowercaseFirstCharacter];
        } else {
            camelStyle = [camelStyle stringByAppendingString:[obj capitalizeFirstCharacter]];
        }
    }];
    return camelStyle;
}

@end
