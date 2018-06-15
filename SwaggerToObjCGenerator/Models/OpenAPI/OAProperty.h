//
//  OAProperty.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/13/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "BaseModel.h"
#import "OAObjectType.h"

@interface OAProperty : OAObjectType

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *propertyDescription;
@property (nonatomic, strong) NSArray *enumList;

@end
