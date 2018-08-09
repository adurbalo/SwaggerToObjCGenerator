//
//  NSError+Extension.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/13/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "NSError+Extension.h"
#import "Constants.h"

static const NSInteger kDefaultErrorCode = 1;

@implementation NSError (Extensions)

+ (NSString *)defaultErrorDomain
{
    return @"SwaggerToObjCGenerator";
}

+ (instancetype)errorWithLocalizedDescription:(NSString *)localizedDescription
{
    NSError *error = [[NSError alloc] initWithDomain:[self defaultErrorDomain] code:kDefaultErrorCode userInfo:@{ NSLocalizedDescriptionKey : localizedDescription?:@""}];
    return error;
}

- (void)terminate
{
    NSLog(@"ERROR: %@ 🚫🛬", self);
#ifdef UI_APP
    notifyLog(self.localizedDescription);
#else
    exit((int)self.code);
#endif
}


@end
