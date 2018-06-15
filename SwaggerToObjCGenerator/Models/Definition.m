//
//  Definition.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/1/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "Definition.h"
#import "Constants.h"
#import "SettingsManager.h"

@implementation Definition

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"type" forKey:@"type"];
    [keyPathDict setObject:@"required" forKey:@"required"];
    [keyPathDict setObject:@"properties" forKey:@"properties"];
    return keyPathDict;
}

+ (NSValueTransformer *)propertiesJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSMutableArray<Property*> *propertiesArray = [NSMutableArray new];
        
        [value enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSError *error = nil;
            Property *response = [MTLJSONAdapter modelOfClass:[Property class]
                                           fromJSONDictionary:obj
                                                        error:&error];
            if (error) {
                *stop = YES;
                *success = NO;
                NSLog(@"Error: %@", error);
            } else {
                response.name = key;
            }
            
            if (response) {
                [propertiesArray addObject:response];
            }
        }];
        return (propertiesArray.count > 0)?propertiesArray:nil;
    }];
}

#pragma mark - Public

- (NSString *)className
{
    return [NSString stringWithFormat:@"%@%@", [SettingsManager sharedManager].prefix, [self.name capitalizeFirstCharacter]];
}

- (NSString *)machineDeclarationFromTemplate:(NSString*)templateString
{
    NSMutableString *declaration = [[NSMutableString alloc] initWithString:templateString];
    NSString *className = [NSString stringWithFormat:@"_%@", [self className]];
    [declaration replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, declaration.length)];
    [declaration replaceOccurrencesOfString:SUPERCLASS_NAME_MARKER withString:[[SettingsManager sharedManager] definitionsSuperclassName] options:0 range:NSMakeRange(0, declaration.length)];
    
    NSMutableSet<NSString *> *customTypes = [NSMutableSet new];
    NSMutableString *propertiesDeclaration = [NSMutableString new];
    
    __block BOOL importEnums = NO;
    [self.properties enumerateObjectsUsingBlock:^(Property * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.enumList.count > 0) {
            importEnums = YES;
            [propertiesDeclaration appendFormat:@"@property (nonatomic) %@%@;\n", [obj objC_fullTypeName], objC_parameterNameFromSwaggerParameter(obj.name)];
            
            if (obj.enumList.count > 0) {
                [[SettingsManager sharedManager] addEnumName:obj.name withOptions:obj.enumList];
            }
            
        } else {
            [propertiesDeclaration appendFormat:@"@property (nonatomic, strong) %@%@;\n", [obj objC_fullTypeName], objC_parameterNameFromSwaggerParameter(obj.name)];
        }
        
        [[obj allTypes] enumerateObjectsUsingBlock:^(NSString * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
            if (isCustomClassType(type)) {
                [customTypes addObject:type];
            }
        }];
    }];
    
    NSMutableString *imports = [NSMutableString new];
    [customTypes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [imports appendFormat:@"#import \"%@.h\"\n", obj];
        //[imports appendFormat:@"@class %@;\n", obj];
    }];
    
    [declaration replaceOccurrencesOfString:CLASS_DECLARATION_MARKER withString:propertiesDeclaration options:0 range:NSMakeRange(0, declaration.length)];
    [declaration replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:imports options:0 range:NSMakeRange(0, declaration.length)];
    
    return declaration;
}

- (NSString *)machineImplementationFromTemplate:(NSString *)templateString
{
    NSMutableString *implamentation = [[NSMutableString alloc] initWithString:templateString];
    NSString *className = [NSString stringWithFormat:@"_%@", [self className]];
    [implamentation replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, implamentation.length)];
    [implamentation replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:@"" options:0 range:NSMakeRange(0, implamentation.length)];
    
    NSMutableString *mappedKeysByPropertiesMethod = [NSMutableString new];
    NSString *dictionaryVariableName = @"mappedKeysByProperties";
    
    [mappedKeysByPropertiesMethod appendFormat:@"+ (NSDictionary<NSString *, NSString *> *)mappedKeysByProperties\n{\n\tstatic NSMutableDictionary<NSString *, NSString *> *%@ = nil;\n\tif (!%@) {\n\t\t%@ = [[NSMutableDictionary alloc] init];\n", dictionaryVariableName, dictionaryVariableName, dictionaryVariableName];
    [mappedKeysByPropertiesMethod appendFormat:@"\t\tif([super mappedKeysByProperties]) {\n\t\t\t[%@ addEntriesFromDictionary:[super mappedKeysByProperties]];\n\t\t}\n", dictionaryVariableName];
    
    
    NSMutableString *enumNameMethodString = [NSMutableString new];
    [enumNameMethodString appendFormat:@"+ (NSString *)enumNameForMappedField:(NSString*)fieldName\n{\n"];
    NSMutableString *classNameOfMembersString = [NSMutableString new];
    [classNameOfMembersString appendFormat:@"+ (NSString *)classNameOfMembersForMappedField:(NSString*)fieldName\n{\n"];
    
    [self.properties enumerateObjectsUsingBlock:^(Property * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [mappedKeysByPropertiesMethod appendFormat:@"\t\t%@[@\"%@\"] = @\"%@\";\n", dictionaryVariableName, obj.name, objC_parameterNameFromSwaggerParameter(obj.name)];

        if (obj.enumList.count) {
            [enumNameMethodString appendFormat:@"\tif ([fieldName isEqualToString:@\"%@\"]) return %@;\n", objC_parameterNameFromSwaggerParameter(obj.name), enumTypeNameConstantNameByParameterName(obj.name)];
        }
        if ([obj objC_genericTypeName]) {
            [classNameOfMembersString appendFormat:@"\tif ([fieldName isEqualToString:@\"%@\"]) return @\"%@\";\n", objC_parameterNameFromSwaggerParameter(obj.name), [obj objC_genericTypeName]];
        }
    }];
    
    [mappedKeysByPropertiesMethod appendFormat:@"\t}\n\treturn %@;\n}\n", dictionaryVariableName];
    [enumNameMethodString appendFormat:@"\treturn [super enumNameForMappedField:fieldName];\n}\n"];
    [classNameOfMembersString appendString:@"\treturn [super classNameOfMembersForMappedField:fieldName];\n}\n"];
    
    [implamentation replaceOccurrencesOfString:CLASS_IMPLEMENTATION_MARKER withString:[NSString stringWithFormat:@"%@\n%@\n%@", mappedKeysByPropertiesMethod, enumNameMethodString, classNameOfMembersString] options:0 range:NSMakeRange(0, implamentation.length)];
    return implamentation;
}

- (NSString *)humanDeclarationFromTemplate:(NSString *)templateString
{
    NSMutableString *declaration = [[NSMutableString alloc] initWithString:templateString];
    NSString *className = [self className];
    [declaration replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, declaration.length)];
    [declaration replaceOccurrencesOfString:SUPERCLASS_NAME_MARKER withString:[NSString stringWithFormat:@"_%@", className] options:0 range:NSMakeRange(0, declaration.length)];
    [declaration replaceOccurrencesOfString:CLASS_DECLARATION_MARKER withString:@"" options:0 range:NSMakeRange(0, declaration.length)];
    [declaration replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:@"" options:0 range:NSMakeRange(0, declaration.length)];
    return declaration;
}

- (NSString *)humanImplementationFromTemplate:(NSString *)templateString
{
    NSMutableString *implamentation = [[NSMutableString alloc] initWithString:templateString];
    [implamentation replaceOccurrencesOfString:CLASS_NAME_MARKER withString:[self className] options:0 range:NSMakeRange(0, implamentation.length)];
    [implamentation replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:@"" options:0 range:NSMakeRange(0, implamentation.length)];
    [implamentation replaceOccurrencesOfString:CLASS_IMPLEMENTATION_MARKER withString:@"" options:0 range:NSMakeRange(0, implamentation.length)];
    return implamentation;;
}

//

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
    return implamentation;;
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
    
    __block BOOL importEnums = NO;
    [self.properties enumerateObjectsUsingBlock:^(Property * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.propertyDescription.length > 0) {
            [propertiesDeclaration appendString:[obj.propertyDescription documentationStyleString]];
        }
        
        if (obj.enumList.count > 0) {
            importEnums = YES;
            [propertiesDeclaration appendFormat:@"@property (nonatomic) %@%@;\n", [obj objC_fullTypeName], objC_parameterNameFromSwaggerParameter(obj.name)];
            
            if (obj.enumList.count > 0) {
                [[SettingsManager sharedManager] addEnumName:obj.name withOptions:obj.enumList];
            }
            
        } else {
            [propertiesDeclaration appendFormat:@"@property (nonatomic, strong) %@%@;\n", [obj objC_fullTypeName], objC_parameterNameFromSwaggerParameter(obj.name)];
        }
        
        [[obj allTypes] enumerateObjectsUsingBlock:^(NSString * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
            if (isCustomClassType(type)) {
                [customTypes addObject:type];
            }
        }];
    }];
    
    NSMutableString *imports = [NSMutableString new];
    [customTypes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [imports appendFormat:@"#import \"%@.h\"\n", obj];
        //[imports appendFormat:@"@class %@;\n", obj];
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
    [enumNameMethodString appendFormat:@"+ (NSString *)enumNameForMappedField:(NSString*)fieldName\n{\n"];
    NSMutableString *classNameOfMembersString = [NSMutableString new];
    [classNameOfMembersString appendFormat:@"+ (NSString *)classNameOfMembersForMappedField:(NSString*)fieldName\n{\n"];
    
    [self.properties enumerateObjectsUsingBlock:^(Property * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [mappedKeysByPropertiesMethod appendFormat:@"\t\t%@[@\"%@\"] = @\"%@\";\n", dictionaryVariableName, obj.name, objC_parameterNameFromSwaggerParameter(obj.name)];
        
        if (obj.enumList.count) {
            [enumNameMethodString appendFormat:@"\tif ([fieldName isEqualToString:@\"%@\"]) return %@;\n", objC_parameterNameFromSwaggerParameter(obj.name), enumTypeNameConstantNameByParameterName(obj.name)];
        }
        if ([obj objC_genericTypeName]) {
            [classNameOfMembersString appendFormat:@"\tif ([fieldName isEqualToString:@\"%@\"]) return @\"%@\";\n", objC_parameterNameFromSwaggerParameter(obj.name), [obj objC_genericTypeName]];
        }
    }];
    
    [mappedKeysByPropertiesMethod appendFormat:@"\t}\n\treturn %@;\n}\n", dictionaryVariableName];
    [enumNameMethodString appendFormat:@"\treturn [super enumNameForMappedField:fieldName];\n}\n"];
    [classNameOfMembersString appendString:@"\treturn [super classNameOfMembersForMappedField:fieldName];\n}\n"];
    
    [implamentation replaceOccurrencesOfString:CLASS_IMPLEMENTATION_MARKER withString:[NSString stringWithFormat:@"%@\n%@\n%@", mappedKeysByPropertiesMethod, enumNameMethodString, classNameOfMembersString] options:0 range:NSMakeRange(0, implamentation.length)];
    return implamentation;
}

@end
