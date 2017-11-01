//
//  Response.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/1/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "BaseModel.h"
#import "Schema.h"

@interface Response : BaseModel

@property (nonatomic) NSInteger code;
@property (nonatomic, strong) NSString *responseDescription;
@property (nonatomic, strong) Schema *schema;

@end
