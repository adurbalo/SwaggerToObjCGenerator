//
//  Path.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 10/31/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "BaseModel.h"
#import "PathParameter.h"
#import "Response.h"
#import "Protocols.h"

@interface Path : BaseModel <GeneratablePath>

@property (nonatomic, strong) NSString *method;
@property (nonatomic, strong) NSString *pathString;

@property (nonatomic, strong) NSArray<NSString *> *tags;
@property (nonatomic, strong) NSString *summary;

@property (nonatomic, strong) NSString *pathDescription;
@property (nonatomic, strong) NSString *operationId;
@property (nonatomic, strong) NSArray<NSString *> *produces;
@property (nonatomic, strong) NSArray<PathParameter *> *parameters;
@property (nonatomic, strong) NSArray<Response*> *responses;

- (NSString *)apiConstVariableName;

- (NSString *)methodDeclarationName;
- (NSString *)methodImplementation;

- (NSSet<NSString*> *)customClassesNames;

@end
