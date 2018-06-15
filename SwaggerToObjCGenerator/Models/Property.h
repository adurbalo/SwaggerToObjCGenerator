//
//  Property.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/1/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "BaseModel.h"
#import "Schema.h"

@interface Property : Schema

@property(nonatomic, strong) NSString *format;
@property(nonatomic, strong) NSString *propertyDescription;

@end
