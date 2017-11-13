//
//  NSError+Extension.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/13/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (Extension)

+ (instancetype)errorWithLocalizedDescription:(NSString *)localizedDescription;
- (void)terminate;

@end
