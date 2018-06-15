//
//  OAServer.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/13/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "BaseModel.h"

@interface OAServer : BaseModel

@property (nonatomic, strong) NSString *url;
@property (nonatomic, strong) NSString *serverDescription;


@end
