//
//  OASchema.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/13/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "BaseModel.h"
#import "OAProperty.h"
#import "Protocols.h"
#import "OAObjectType.h"
/*
 @property (nonatomic, strong) NSString *type;
 @property (nonatomic, strong) NSString *ref;
 @property (nonatomic, strong) OAObjectType *items;
 @property (nonatomic, strong) NSString *format;
*/

@interface OASchema : OAObjectType <GeneratableDTO>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSArray<OAProperty *> *properties;

- (NSString *)className;
- (NSString *)humanClassDeclaration;
- (NSString *)humanClassImplementation;
- (NSString *)machineClassDeclaration;
- (NSString *)machineClassImplementation;

@end
