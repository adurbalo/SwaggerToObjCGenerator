//
//  Info.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 10/31/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "BaseModel.h"

@interface Info : BaseModel

@property (nonatomic, strong) NSString *infoDescription;
@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *termsOfService;
@property (nonatomic, strong) id contact;
@property (nonatomic, strong) id license;

@end
