//
//  Generator.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/14/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"

@interface Generator : NSObject

- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithGeneratableObject:(id<Generatable>)generatable;

- (void)start;

@end
