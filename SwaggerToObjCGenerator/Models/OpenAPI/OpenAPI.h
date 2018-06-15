//
//  OpenAPI.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/12/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "BaseModel.h"
#import "Protocols.h"

@class Info, Path, Components, OAServer;

@interface OpenAPI : BaseModel <Generatable>

@property (nonatomic, copy) NSString *openapi;
@property (nonatomic, strong) Info *info;
@property (nonatomic, strong) NSDictionary<NSString*, NSArray<Path*> *> *paths;
@property (nonatomic, strong) Components *components;
@property (nonatomic, strong) NSArray<OAServer *> *servers;

@end
