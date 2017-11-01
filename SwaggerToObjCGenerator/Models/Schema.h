//
//  Schema.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/1/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "BaseModel.h"

@interface Schema : BaseModel

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDictionary *items;


@end
