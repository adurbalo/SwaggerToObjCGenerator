//
//  Components.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/12/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "BaseModel.h"
#import "Schema.h"

@interface Components : BaseModel

@property (nonatomic, strong) Schema *scheme;

@end
