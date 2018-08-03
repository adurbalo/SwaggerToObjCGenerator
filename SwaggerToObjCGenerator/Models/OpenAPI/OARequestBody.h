//
//  OARequestBody.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 7/2/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "BaseModel.h"
#import "OAContent.h"

@interface OARequestBody : BaseModel

@property (nonatomic) BOOL required;
@property (nonatomic, strong) OAContent *content;

@end
