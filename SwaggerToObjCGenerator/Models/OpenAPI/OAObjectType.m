 //
//  OAObjectType.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/15/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "OAObjectType.h"
#import "Constants.h"
#import "DataManager.h"
#import "OASchema.h"

@implementation OAObjectType

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"type" forKey:@"type"];
    [keyPathDict setObject:@"$ref" forKey:@"ref"];
    [keyPathDict setObject:@"items" forKey:@"items"];
    [keyPathDict setObject:@"format" forKey:@"format"];
    [keyPathDict setObject:@"enum" forKey:@"enumList"];
    [keyPathDict setObject:@"pattern" forKey:@"pattern"];
    return keyPathDict;
}

+ (NSValueTransformer *)itemsJSONTransformer {
    return [MTLJSONAdapter dictionaryTransformerWithModelClass:OAObjectType.class];
}

#pragma mark - Internal

- (OASchema *)currentOASchema
{
    if (self.items) {
        if (self.items.ref) {
            OASchema *schema = [[DataManager sharedManager] oaSchemaByName:self.items.ref];
            return schema;
        }
    } else if (self.ref) {
        OASchema *schema = [[DataManager sharedManager] oaSchemaByName:self.ref];
        return schema;
    } else if ([self isKindOfClass:[OASchema class]]) {
        OASchema *schema = (OASchema*)self;
        return schema;
    }
    return nil;
}

- (NSString *)objC_classNameByObjectType:(OAObjectType *)objectType
{
    NSArray *toNumberTypes = @[@"integer",
                               @"long",
                               @"float",
                               @"double",
                               @"boolean",
                               @"number" //Not sure about OpenAPI support
                               ];
    
    NSString *objCNameClass = nil;
    if ([objectType.type isEqualToString:@"string"]) {
        
        if ([objectType.format isEqualToString:@"date-time"]) {
            objCNameClass = [[SettingsManager sharedManager] typeNameWithType:@"DateTimeBox"];
        } else if ([objectType.format isEqualToString:@"date"]) {
            objCNameClass = [[SettingsManager sharedManager] typeNameWithType:@"DateBox"];
        } else {
            objCNameClass = @"NSString";
        }
    } else if ([objectType.type isEqualToString:@"array"]) {
        objCNameClass = @"NSArray";
    } else if ([objectType.type isEqualToString:@"object"]) {
        objCNameClass = @"NSDictionary";
    } else if ([toNumberTypes containsObject:objectType.type]) {
        objCNameClass = @"NSNumber";
    } else {
        //NSLog(@"Custom type: %@ ?", swaggerType);
        objCNameClass = [[SettingsManager sharedManager] typeNameWithType:objectType.type];
    }
    return objCNameClass;
}

#pragma mark - Public

- (NSString *)objc_CustomTypeName
{
    NSString *result = nil;
    
    OASchema *schema = [self currentOASchema];
    if (schema) {
        if ([schema isEnumType]) {
            return nil;
        }
        result = [schema targetClassName]?:[self objC_classNameByObjectType:schema];
    } else if (self.type) {
        result = [NSString stringWithFormat:@"%@ *", [self objC_classNameByObjectType:self]];
    }
    
    if (isCustomClassType(result)) {
        return result;
    }
    return nil;
}

- (NSString *)objc_FullTypeName
{
    NSString *result = nil;
    
    OASchema *schema = [self currentOASchema];
    if (schema) {
        if ([schema isEnumType]) {
            result = [NSString stringWithFormat:@"%@ ", enumTypeNameByParameterName(schema.name)];
        } else {
            NSString *targetClassName = [schema targetClassName]?:[self objC_classNameByObjectType:schema];
            if (self.items) {
                result = [NSString stringWithFormat:@"NSArray <%@ *> *", targetClassName];
            } else {
                result = [NSString stringWithFormat:@"%@ *", targetClassName];
            }
        }
    } else if (self.type) {
        result = [NSString stringWithFormat:@"%@ *",  [self objC_classNameByObjectType:self]];
    }
    return result;
}

- (BOOL)isEnumType
{
    if (self.enumList) {
        return YES;
    }
    if (self.ref) {
        OASchema *schema = [[DataManager sharedManager] oaSchemaByName:self.ref];
        return [schema isEnumType];
    }
    return NO;
}

- (NSString *)enumTypeConstantName
{
    if (![self isEnumType]) {
        return nil;
    }
    NSString *name = nil;
    if ([self isKindOfClass:[OASchema class]]) {
        OASchema *schema = (OASchema*)self;
        if (schema.ref) {
            OASchema *sch = [[DataManager sharedManager] oaSchemaByName:schema.ref];
            name = [NSString stringWithFormat:@"%@", enumTypeNameByParameterName(sch.name)];
        } else {
            name = [NSString stringWithFormat:@"%@", enumTypeNameByParameterName(schema.name)];
        }
    } else if (self.ref) {
        OASchema *schema = [[DataManager sharedManager] oaSchemaByName:self.ref];
        name = [NSString stringWithFormat:@"%@", enumTypeNameByParameterName(schema.name)];
    }
    if (name) {
        return [NSString stringWithFormat:@"k%@Name", name];
    }
    return nil;
}

- (NSString *)targetClassName
{
    OASchema *currentScheme = [self currentOASchema];
    if (!currentScheme.name || [currentScheme isEnumType]) {
        return nil;
    }
    return [currentScheme className];
}

- (BOOL)isDateType
{
    return [[self objc_FullTypeName] hasPrefix:[NSString stringWithFormat:@"%@Date", [SettingsManager sharedManager].prefix]];
}

@end
