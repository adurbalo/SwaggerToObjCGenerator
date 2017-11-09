//
//  Swagger.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 10/31/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "BaseModel.h"
#import "Info.h"
#import "Path.h"
#import "Definition.h"
#import "Service.h"

@interface Swagger : BaseModel

@property (nonatomic, strong) NSString *swagger;
@property (nonatomic, strong) Info *info;
@property (nonatomic, strong) NSString *basePath;
@property (nonatomic, strong) NSArray<NSDictionary *> *tags;
@property (nonatomic, strong) NSArray<NSString *> *schemes;
@property (nonatomic, strong) NSDictionary<NSString*, NSArray<Path*> *> *paths;
@property (nonatomic, strong) NSDictionary *securityDefinitions;
@property (nonatomic, strong) NSArray<Definition*> *definitions;

@end
