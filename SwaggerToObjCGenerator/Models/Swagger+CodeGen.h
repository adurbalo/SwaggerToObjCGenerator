//
//  Swagger+CodeGen.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/2/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "Swagger.h"

@interface Swagger (CodeGen)

- (void)generateParentServiceResource;
- (void)generateServicesClasses;
- (void)generateBaseEntity;
- (void)generateDefinitionsClasses;
- (void)generateEnumsClass;

@end
