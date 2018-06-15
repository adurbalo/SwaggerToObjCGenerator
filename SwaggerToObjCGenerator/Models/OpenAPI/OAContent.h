//
//  OAContent.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/15/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "BaseModel.h"

@class OASchema;

@interface OAContent : BaseModel

@property (nonatomic, strong) NSString *contentType;
@property (nonatomic, strong) OASchema *schema;

@end
