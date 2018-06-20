//
//  PathParameter.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/1/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "BaseModel.h"
#import "Schema.h"

@class OASchema;

@interface PathParameter : Schema

@property (nonatomic, strong) NSString *placedIn;
@property (nonatomic) BOOL required;
@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) Schema *schema;
@property (nonatomic, strong) OASchema *oaSchema;

- (Schema*)currentSchema;

@end
