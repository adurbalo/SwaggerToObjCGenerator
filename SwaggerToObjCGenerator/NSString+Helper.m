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

@end
