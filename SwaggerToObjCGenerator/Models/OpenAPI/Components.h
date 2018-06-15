//
//  Components.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/12/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "BaseModel.h"
#import "OASchema.h"

@interface Components : BaseModel

@property (nonatomic, strong) NSArray<OASchema *> *schemas;

@end
