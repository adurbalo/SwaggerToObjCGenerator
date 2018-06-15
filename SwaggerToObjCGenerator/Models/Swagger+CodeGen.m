//
//  Swagger+CodeGen.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/2/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "Swagger+CodeGen.h"
#import "NSString+Helper.h"
#import "Constants.h"
#import "SettingsManager.h"
#import "NSError+Extension.h"
#import "CodeGeneratorHelper.h"
#import "FilesHandler.h"

@implementation Swagger (CodeGen)

#pragma mark - Preparation

- (NSDictionary<NSString*, NSArray<Path*> *> *)splitedPathsByServices
{
    NSMutableDictionary<NSString*, NSArray<Path*> *> *splitedDictionary = [NSMutableDictionary new];
    
    NSMutableSet<NSString *> *servicesNames = [NSMutableSet new];
    
    [[self.paths allKeys] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *components = [[obj componentsSeparatedByString:@"/"] mutableCopy];
        [components removeObject:@""];
        
        if ([components firstObject]) {
            [servicesNames addObject:[components firstObject]];
        }
    }];
    
    [servicesNames enumerateObjectsUsingBlock:^(NSString * _Nonnull serviceName, BOOL * _Nonnull stop) {
        
        NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSString * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
            
            if (![evaluatedObject hasPrefix:[NSString stringWithFormat:@"/%@/", serviceName]]) {
                return NO;
            }
            return YES;
        }];
        NSArray<NSString*> *filteredKeys = [[self.paths allKeys] filteredArrayUsingPredicate:predicate];
        
        NSMutableArray<Path*> *pathsForService = [NSMutableArray new];
        
        [filteredKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSArray<Path*> *pathsArray = self.paths[obj];
            if (pathsArray.count > 0) {
                [pathsForService addObjectsFromArray:pathsArray];
            }
        }];
        
        if (pathsForService.count) {
            splitedDictionary[serviceName] = pathsForService;
        }
    }];
    
    return splitedDictionary;
}

- (void)generateServicesClasses
{
    NSDictionary<NSString*, NSArray<Path*> *> *pathsByResources = [self splitedPathsByServices];
    
    NSMutableString *apiFileContent = [NSMutableString new];
    
    NSMutableString *abstractServerContent_H_fileContent = [NSMutableString new];
    NSMutableString *abstractServerClassDerectiveDeclaration_H_Content = [NSMutableString new];
    NSMutableString *abstractServerClassIvarsDeclaration_H_Content = [[NSMutableString alloc] initWithString:@"\t@protected\n"];
    
    NSMutableString *abstractServerContent_M_fileContent = [NSMutableString new];
    NSMutableString *abstractServerImports_M_fileContent = [NSMutableString new];
    
    [pathsByResources enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull resourceName, NSArray<Path *> * _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString *resorceClassName = [self generateH_FileForResourceName:resourceName withPaths:obj];
        [self generateM_FileForResourceName:resourceName withPaths:obj];
        
        [apiFileContent setString:[NSString stringWithFormat:@"%@\n%@", apiFileContent, [CodeGeneratorHelper APIFileCodeForResourceName:resourceName withPaths:obj]]];
        [abstractServerContent_H_fileContent setString:[NSString stringWithFormat:@"%@ %@", abstractServerContent_H_fileContent, [CodeGeneratorHelper abstractServerDefinitionForResourceName:resourceName andResourceClassName:resorceClassName]]];
        [abstractServerClassDerectiveDeclaration_H_Content setString:[NSString stringWithFormat:@"%@@class %@;\n", abstractServerClassDerectiveDeclaration_H_Content,resorceClassName]];
        [abstractServerClassIvarsDeclaration_H_Content appendFormat:@"\t%@ *_%@;\n", resorceClassName, resourceName];
        
        [abstractServerContent_M_fileContent setString:[NSString stringWithFormat:@"%@ %@", abstractServerContent_M_fileContent, [CodeGeneratorHelper abstractServerImplementationForResourceName:resourceName andResourceClassName:resorceClassName]]];
        [abstractServerImports_M_fileContent setString:[NSString stringWithFormat:@"%@#import \"%@.h\"\n", abstractServerImports_M_fileContent, resorceClassName]];
    }];
    
    [CodeGeneratorHelper generateAPIConstantsFileWithContent:apiFileContent];
    [CodeGeneratorHelper generateAbstractServerFile_H_WithContent:abstractServerContent_H_fileContent withClassesDerectiveDeclaration:abstractServerClassDerectiveDeclaration_H_Content andIvarsDeclaration:abstractServerClassIvarsDeclaration_H_Content];
    [CodeGeneratorHelper generateAbstractServerFile_M_WithContent:abstractServerContent_M_fileContent withImports:abstractServerImports_M_fileContent];
}

#pragma mark - Resources

- (NSString *)generateH_FileForResourceName:(NSString*)resourceName withPaths:(NSArray<Path*> *)paths
{
    NSString *className = [NSString stringWithFormat:@"%@%@ServiceResource", [SettingsManager sharedManager].prefix, [resourceName capitalizeFirstCharacter]];
    NSString *resourcesDirectory = [[SettingsManager sharedManager].destinationPath stringByAppendingPathComponent:@"Resources"];
    [FilesHandler createDirectoryForPathIfNeeded:resourcesDirectory];
    
    NSString *fullFilePath = [[resourcesDirectory stringByAppendingPathComponent:className] stringByAppendingString:@".h"];
    
    NSMutableString *hContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"ObjectiveCClassTemplate.h"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    //Generate Class name
    [hContentOfFile replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    NSMutableString *methodsDeclarationString = [NSMutableString new];
    NSMutableSet<NSString *> *customClassesNames = [NSMutableSet new];
    
    
    [paths enumerateObjectsUsingBlock:^(Path * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *methodName = [obj methodDeclarationName];
        [methodsDeclarationString appendFormat:@"%@;\n", methodName];
        [customClassesNames addObjectsFromArray:[[obj customClassesNames] allObjects]];
    }];
    
    //Generate Methods
    [hContentOfFile replaceOccurrencesOfString:CLASS_DECLARATION_MARKER withString:methodsDeclarationString options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    [hContentOfFile replaceOccurrencesOfString:SUPERCLASS_NAME_MARKER withString:[[SettingsManager sharedManager] parentServiceRecourseName] options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    //Generate Imports
    NSMutableString *importsString = [NSMutableString new];
    [customClassesNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [importsString appendFormat:@"#import \"%@.h\"\n", obj];
    }];
    [hContentOfFile replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:importsString options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    [FilesHandler writeString:hContentOfFile toFilePath:fullFilePath];
    
    return className;
}

- (void)generateM_FileForResourceName:(NSString*)resourceName withPaths:(NSArray<Path*> *)paths
{
    NSString *className = [NSString stringWithFormat:@"%@%@ServiceResource", [SettingsManager sharedManager].prefix, [resourceName capitalizeFirstCharacter]];
    NSString *resourcesDirectory = [[SettingsManager sharedManager].destinationPath stringByAppendingPathComponent:@"Resources"];
    [FilesHandler createDirectoryForPathIfNeeded:resourcesDirectory];
    
    NSString *fullFilePath = [[resourcesDirectory stringByAppendingPathComponent:className] stringByAppendingString:@".m"];
    
    NSMutableString *mContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"ObjectiveCClassTemplate.m"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    //Import Api Const
    [mContentOfFile replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:[NSString stringWithFormat:@"#import \"%@.h\"", [[SettingsManager sharedManager] apiConstantName]] options:0 range:NSMakeRange(0, mContentOfFile.length)];
    
    //Generate Class name
    [mContentOfFile replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, mContentOfFile.length)];
    
    NSMutableString *methodsImplementationString = [NSMutableString new];
    
    [paths enumerateObjectsUsingBlock:^(Path * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [methodsImplementationString appendFormat:@"%@\n", [obj methodImplementation]];
    }];
    
    [mContentOfFile replaceOccurrencesOfString:CLASS_IMPLEMENTATION_MARKER withString:methodsImplementationString options:0 range:NSMakeRange(0, mContentOfFile.length)];
    
    [FilesHandler writeString:mContentOfFile toFilePath:fullFilePath];
}

#pragma mark - Definitions

- (void)generateDefinitionsClasses
{
    NSString *objcHtemplate = [[NSString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"ObjectiveCClassTemplate.h"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    NSString *objcMtemplate = [[NSString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"ObjectiveCClassTemplate.m"]
                                                                            encoding:NSUTF8StringEncoding
                                                                               error:nil];
    NSString *pathToDefinitionDir = [[SettingsManager sharedManager].destinationPath stringByAppendingPathComponent:@"Definitions"];
    NSString *pathToMachineDirectory = [pathToDefinitionDir stringByAppendingPathComponent:@"Machine"];
    [FilesHandler createDirectoryForPathIfNeeded:pathToMachineDirectory];
    [FilesHandler clearFilesInDirectoryPath:pathToMachineDirectory];
    
    NSString *pathToHumanDirectory = [pathToDefinitionDir stringByAppendingPathComponent:@"Human"];
    [FilesHandler createDirectoryForPathIfNeeded:pathToHumanDirectory];
    
    [self.definitions enumerateObjectsUsingBlock:^(Definition * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *machineH_Path = [[pathToMachineDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"_%@", [obj className]]] stringByAppendingString:@".h"];
        NSString *machineM_path = [[pathToMachineDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"_%@", [obj className]]] stringByAppendingString:@".m"];
        
        [FilesHandler writeString:[obj machineDeclarationFromTemplate:objcHtemplate] toFilePath:machineH_Path];
        [FilesHandler writeString:[obj machineImplementationFromTemplate:objcMtemplate] toFilePath:machineM_path];
        
        NSString *humanH_Path = [[pathToHumanDirectory stringByAppendingPathComponent:[obj className]] stringByAppendingString:@".h"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:humanH_Path]) {
            [FilesHandler writeString:[obj humanDeclarationFromTemplate:objcHtemplate] toFilePath:humanH_Path];
        }
        
        NSString *humanM_path = [[pathToHumanDirectory stringByAppendingPathComponent:[obj className]] stringByAppendingString:@".m"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:humanM_path]) {
            [FilesHandler writeString:[obj humanImplementationFromTemplate:objcMtemplate] toFilePath:humanM_path];
        }
    }];
}

#pragma mark - Enums

- (void)generateEnumsClass
{
    NSMutableString *objcHtemplate = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"EnumsTemplate_h"]
                                                              encoding:NSUTF8StringEncoding
                                                                 error:nil];
    NSMutableString *objcMtemplate = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"EnumsTemplate_m"]
                                                                            encoding:NSUTF8StringEncoding
                                                                               error:nil];
    
    NSMutableString *h_importSection = [[NSMutableString alloc] init];
    NSMutableString *m_implementationSection = [[NSMutableString alloc] init];
    
    [@{}/*[SettingsManager sharedManager].enumsDictionary*/ enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<NSString *> * _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSMutableString *h_enumDeclaration = [[NSMutableString alloc] init];
        NSMutableString *h_constantsDeclaration = [[NSMutableString alloc] init];
        
        [h_enumDeclaration appendFormat:@"\ntypedef NS_ENUM(NSUInteger, %@) {\n", enumTypeNameByParameterName(key)];
        [h_constantsDeclaration appendFormat:@"static NSString *const %@ = @\"%@\";\n", enumTypeNameConstantNameByParameterName(key), enumTypeNameByParameterName(key)];
        [h_constantsDeclaration appendFormat:@"static NSUInteger const k%@Count = %zd;\n", enumTypeNameByParameterName(key), obj.count];
        
        [m_implementationSection appendFormat:@"\n+ (NSDictionary<NSString *, NSNumber *> *)%@Dictionary\n{\n", enumTypeNameByParameterName(key)];
        [m_implementationSection appendString:@"\tNSMutableDictionary<NSString *, NSNumber *> *dictionary = [NSMutableDictionary new];\n"];
        
        [obj enumerateObjectsUsingBlock:^(NSString * _Nonnull enumValue, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                [h_enumDeclaration appendFormat:@"\t%@ = 1", enumValueName(enumTypeNameByParameterName(key), enumValue)];
            } else {
                [h_enumDeclaration appendFormat:@",\n\t%@", enumValueName(enumTypeNameByParameterName(key), enumValue)];
            }
            
            NSString *constVarName = [NSString stringWithFormat:@"k%@String", enumValueName(enumTypeNameByParameterName(key), enumValue)];
            [h_constantsDeclaration appendFormat:@"static NSString *const %@ = @\"%@\";\n", constVarName, enumValue];
            
            [m_implementationSection appendFormat:@"\tdictionary[%@] = @(%zd);\n", constVarName, idx+1];
        }];
        [h_enumDeclaration appendString:@"\n};\n"];
        [h_importSection appendFormat:@"%@\n%@", h_enumDeclaration, h_constantsDeclaration];
        
        [m_implementationSection appendString:@"\treturn dictionary;\n}\n"];
    }];
    
    NSString *className = [SettingsManager sharedManager].enumsClassName;
    
    [objcHtemplate replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, objcHtemplate.length)];
    [objcHtemplate replaceOccurrencesOfString:SUPERCLASS_NAME_MARKER withString:@"NSObject" options:0 range:NSMakeRange(0, objcHtemplate.length)];
    [objcHtemplate replaceOccurrencesOfString:@"#import \"NSObject.h\"" withString:@"" options:0 range:NSMakeRange(0, objcHtemplate.length)];
    [objcHtemplate replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:h_importSection options:0 range:NSMakeRange(0, objcHtemplate.length)];
    
    NSString *hFilePath = [[SettingsManager sharedManager].destinationPath stringByAppendingPathComponent:[className stringByAppendingString:@".h"]];
    [FilesHandler writeString:objcHtemplate toFilePath:hFilePath];
    
    [objcMtemplate replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, objcMtemplate.length)];
    [objcMtemplate replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:@"" options:0 range:NSMakeRange(0, objcMtemplate.length)];
    [objcMtemplate replaceOccurrencesOfString:CLASS_IMPLEMENTATION_MARKER withString:m_implementationSection options:0 range:NSMakeRange(0, objcMtemplate.length)];
    
    NSString *mFilePath = [[SettingsManager sharedManager].destinationPath stringByAppendingPathComponent:[className stringByAppendingString:@".m"]];
    [FilesHandler writeString:objcMtemplate toFilePath:mFilePath];
}

@end
