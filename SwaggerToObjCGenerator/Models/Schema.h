//
//  Schema.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/1/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "BaseModel.h"

@interface Schema : BaseModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *itemsType;
@property (nonatomic, strong) NSString *reference;
@property (nonatomic, strong) NSArray *enumList;

- (NSString *)objC_mainTypeName;
- (NSString *)objC_genericTypeName;
- (NSString *)objC_fullTypeName;

- (NSArray<NSString *> *)allTypes;

@end
