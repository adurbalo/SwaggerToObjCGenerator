//
//  OAProperty.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/13/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "BaseModel.h"

@class OASchema;

@interface OAProperty : BaseModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *ref;
@property (nonatomic, strong) OASchema *items;
@property (nonatomic, strong) NSArray *enumList;

@end
