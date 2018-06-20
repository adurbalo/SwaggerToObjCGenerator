//
//  NSString+Helper.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/3/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Helper)

- (NSString *)capitalizeFirstCharacter;
- (NSString *)lowercaseFirstCharacter;
- (NSString *)documentationStyleString;
- (NSString *)camelCaseStyleSting;

@end
