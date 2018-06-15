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

@interface OASchema : BaseModel <GeneratableDTO>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSArray<OAProperty *> *properties;
@property (nonatomic, strong) NSArray *enumList;


- (NSString *)className;
- (NSString *)humanClassDeclaration;
- (NSString *)humanClassImplementation;
- (NSString *)machineClassDeclaration;
- (NSString *)machineClassImplementation;

@end
