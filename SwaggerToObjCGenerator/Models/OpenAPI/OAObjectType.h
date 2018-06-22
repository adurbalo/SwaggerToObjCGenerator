//
//  OAObjectType.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/15/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "BaseModel.h"

@interface OAObjectType : BaseModel

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *ref;
@property (nonatomic, strong) OAObjectType *items;
@property (nonatomic, strong) NSString *format;
@property (nonatomic, strong) NSArray *enumList;

- (NSString *)objc_CustomTypeName;
- (NSString *)objc_FullTypeName;
- (BOOL)isEnumType;
- (NSString *)enumTypeConstantName;
- (NSString *)targetClassName;
- (BOOL)isDateType;

@end
