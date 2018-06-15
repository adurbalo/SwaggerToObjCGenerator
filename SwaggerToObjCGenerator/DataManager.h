//
//  DataManager.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/15/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Schema, OASchema;

@interface DataManager : NSObject

+ (instancetype)sharedManager;

- (void)addOASchemas:(NSArray<OASchema *> *)schemas;
- (OASchema *)oaSchemaByName:(NSString *)name;


- (void)addSchemas:(NSArray<Schema *> *)schemas;

@end
