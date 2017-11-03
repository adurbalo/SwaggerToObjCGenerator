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

@end
