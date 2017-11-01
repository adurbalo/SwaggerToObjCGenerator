//
//  Property.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/1/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "BaseModel.h"

@interface Property : BaseModel

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *type;
@property(nonatomic, strong) NSString *format;
@property(nonatomic, strong) NSArray<NSString *> *enumList;
@property(nonatomic, strong) NSString *reference;

@end
