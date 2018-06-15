//
//  Definition.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/1/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "BaseModel.h"
#import "Property.h"
#import "Protocols.h"

@interface Definition : BaseModel <GeneratableDTO>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSArray<NSString *> *required;
@property (nonatomic, strong) NSArray<Property *> *properties;

- (NSString *)className;

- (NSString *)machineDeclarationFromTemplate:(NSString*)templateString;
- (NSString *)machineImplementationFromTemplate:(NSString*)templateString;

- (NSString *)humanDeclarationFromTemplate:(NSString*)templateString;
- (NSString *)humanImplementationFromTemplate:(NSString*)templateString;

- (NSString *)humanClassDeclaration;
- (NSString *)humanClassImplementation;
- (NSString *)machineClassDeclaration;
- (NSString *)machineClassImplementation;

@end
