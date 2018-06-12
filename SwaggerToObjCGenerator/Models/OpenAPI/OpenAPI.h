//
//  OpenAPI.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/12/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "BaseModel.h"
#import "Protocols.h"
#import "Info.h"
#import "Path.h"

@interface OpenAPI : BaseModel <Generatable>

@property (nonatomic, copy) NSString *openapi;
@property (nonatomic, strong) Info *info;
@property (nonatomic, strong) NSDictionary<NSString*, NSArray<Path*> *> *paths;

@end
