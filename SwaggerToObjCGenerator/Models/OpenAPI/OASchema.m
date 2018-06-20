//
//  OASchema.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/13/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "OASchema.h"
#import "Constants.h"
#import "DataManager.h"

@implementation OASchema

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"type" forKey:@"type"];
    [keyPathDict setObject:@"properties" forKey:@"properties"];
    return keyPathDict;
}

+ (NSValueTransformer *)propertiesJSONTransformer
{
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSMutableArray<OAProperty *> *properties = [NSMutableArray new];
        
        [value enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSError *error = nil;
            OAProperty *property = [MTLJSONAdapter modelOfClass:[OAProperty class]
                                         fromJSONDictionary:obj
                                                      error:&error];
            if (error) {
                *stop = YES;
                *success = NO;
                NSLog(@"Error: %@", error);
            } else {
                property.name = key;
                [properties addObject:property];
            }
        }];
        
        return properties;
    }];
}

#pragma mark - Public

- (NSString *)className
{
    return [NSString stringWithFormat:@"%@%@", [SettingsManager sharedManager].prefix, [self.name capitalizeFirstCharacter]];
}

- (NSString *)humanClassDeclaration
{
    NSString *objcHtemplate = [[NSString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"ObjectiveCClassTemplate.h"]
                                                              encoding:NSUTF8StringEncoding
                                                                 error:nil];
    
    NSMutableString *declaration = [[NSMutableString alloc] initWithString:objcHtemplate];
    NSString *className = [self className];
    [declaration replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, declaration.length)];
    [declaration replaceOccurrencesOfString:SUPERCLASS_NAME_MARKER withString:[NSString stringWithFormat:@"_%@", className] options:0 range:NSMakeRange(0, declaration.length)];
    [declaration replaceOccurrencesOfString:CLASS_DECLARATION_MARKER withString:@"" options:0 range:NSMakeRange(0, declaration.length)];
    
    NSMutableSet<NSString *> *customTypes = [NSMutableSet new];
    [self.properties enumerateObjectsUsingBlock:^(OAProperty * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj objc_CustomTypeName]) {
            [customTypes addObject:[obj objc_CustomTypeName]];
        }
    }];
    
    [declaration replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:@"" options:0 range:NSMakeRange(0, declaration.length)];
    return declaration;
}

- (NSString *)humanClassImplementation
{
    NSString *objcMtemplate = [[NSString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"ObjectiveCClassTemplate.m"]
                                                              encoding:NSUTF8StringEncoding
                                                                 error:nil];
    
    NSMutableString *implamentation = [[NSMutableString alloc] initWithString:objcMtemplate];
    [implamentation replaceOccurrencesOfString:CLASS_NAME_MARKER withString:[self className] options:0 range:NSMakeRange(0, implamentation.length)];
    [implamentation replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:@"" options:0 range:NSMakeRange(0, implamentation.length)];
    [implamentation replaceOccurrencesOfString:CLASS_IMPLEMENTATION_MARKER withString:@"" options:0 range:NSMakeRange(0, implamentation.length)];
    return implamentation;
}

- (NSString *)machineClassDeclaration
{
    NSString *objcHtemplate = [[NSString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"ObjectiveCClassTemplate.h"]
                                                              encoding:NSUTF8StringEncoding
                                                                 error:nil];
    
    NSMutableString *declaration = [[NSMutableString alloc] initWithString:objcHtemplate];
    NSString *className = [NSString stringWithFormat:@"_%@", [self className]];
    [declaration replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, declaration.length)];
    [declaration replaceOccurrencesOfString:SUPERCLASS_NAME_MARKER withString:[[SettingsManager sharedManager] definitionsSuperclassName] options:0 range:NSMakeRange(0, declaration.length)];
    
    NSMutableSet<NSString *> *customTypes = [NSMutableSet new];
    NSMutableString *propertiesDeclaration = [NSMutableString new];
    
    

    [self.properties enumerateObjectsUsingBlock:^(OAProperty * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *customType = [obj objc_CustomTypeName];
        if (customType) {
            [customTypes addObject:customType];
        }
        NSString *fullTypeName = [obj objc_FullTypeName];
        if ([obj isEnumType]) {
            [customTypes addObject:[SettingsManager sharedManager].enumsClassName];
            [propertiesDeclaration appendFormat:@"@property (nonatomic) %@%@;\n", fullTypeName, objC_parameterNameFromSwaggerParameter(obj.name)];
        } else {
            [propertiesDeclaration appendFormat:@"@property (nonatomic, strong) %@%@;\n", fullTypeName, objC_parameterNameFromSwaggerParameter(obj.name)];
        }
    }];
    
    NSMutableString *imports = [NSMutableString new];
    [customTypes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [imports appendFormat:@"#import \"%@.h\"\n", obj];
    }];
    
    [declaration replaceOccurrencesOfString:CLASS_DECLARATION_MARKER withString:propertiesDeclaration options:0 range:NSMakeRange(0, declaration.length)];
    [declaration replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:imports options:0 range:NSMakeRange(0, declaration.length)];
    
    return declaration;
}

- (NSString *)machineClassImplementation
{
    NSString *objcMtemplate = [[NSString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"ObjectiveCClassTemplate.m"]
                                                              encoding:NSUTF8StringEncoding
                                                                 error:nil];
    
    NSMutableString *implamentation = [[NSMutableString alloc] initWithString:objcMtemplate];
    NSString *className = [NSString stringWithFormat:@"_%@", [self className]];
    [implamentation replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, implamentation.length)];
    [implamentation replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:@"" options:0 range:NSMakeRange(0, implamentation.length)];
    
    NSMutableString *mappedKeysByPropertiesMethod = [NSMutableString new];
    NSString *dictionaryVariableName = @"mappedKeysByProperties";
    
    [mappedKeysByPropertiesMethod appendFormat:@"+ (NSDictionary<NSString *, NSString *> *)mappedKeysByProperties\n{\n\tstatic NSMutableDictionary<NSString *, NSString *> *%@ = nil;\n\tif (!%@) {\n\t\t%@ = [[NSMutableDictionary alloc] init];\n", dictionaryVariableName, dictionaryVariableName, dictionaryVariableName];
    [mappedKeysByPropertiesMethod appendFormat:@"\t\tif([super mappedKeysByProperties]) {\n\t\t\t[%@ addEntriesFromDictionary:[super mappedKeysByProperties]];\n\t\t}\n", dictionaryVariableName];
    
    NSMutableString *enumNameMethodString = [NSMutableString new];
    NSMutableString *classNameOfMembersString = [NSMutableString new];
    
    [self.properties enumerateObjectsUsingBlock:^(OAProperty * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [mappedKeysByPropertiesMethod appendFormat:@"\t\t%@[@\"%@\"] = @\"%@\";\n", dictionaryVariableName, obj.name, objC_parameterNameFromSwaggerParameter(obj.name)];
        
        if ([obj isEnumType]) {
            [enumNameMethodString appendFormat:@"\tif ([fieldName isEqualToString:@\"%@\"]) return %@;\n", objC_parameterNameFromSwaggerParameter(obj.name), [obj enumTypeConstantName]];
        } else if ([obj objc_CustomTypeName]) {
            [classNameOfMembersString appendFormat:@"\tif ([fieldName isEqualToString:@\"%@\"]) return @\"%@\";\n", objC_parameterNameFromSwaggerParameter(obj.name), [obj objc_CustomTypeName]];
        }
    }];
    
    [mappedKeysByPropertiesMethod appendFormat:@"\t}\n\treturn %@;\n}\n\n", dictionaryVariableName];
    
    if (enumNameMethodString.length > 0) {
        [enumNameMethodString insertString:@"+ (NSString *)enumNameForMappedField:(NSString*)fieldName\n{\n" atIndex:0];
        [enumNameMethodString appendFormat:@"\treturn [super enumNameForMappedField:fieldName];\n}\n\n"];
    }
    
    if (classNameOfMembersString.length > 0) {
        [classNameOfMembersString insertString:@"+ (NSString *)classNameOfMembersForMappedField:(NSString*)fieldName\n{\n" atIndex:0];
        [classNameOfMembersString appendString:@"\treturn [super classNameOfMembersForMappedField:fieldName];\n}\n"];
    }
    
    [implamentation replaceOccurrencesOfString:CLASS_IMPLEMENTATION_MARKER withString:[NSString stringWithFormat:@"%@%@%@", mappedKeysByPropertiesMethod, enumNameMethodString, classNameOfMembersString] options:0 range:NSMakeRange(0, implamentation.length)];
    return implamentation;
}

@end
