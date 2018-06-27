//
//  Generator.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/14/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "Generator.h"
#import "SettingsManager.h"
#import "FilesHandler.h"
#import "Constants.h"

@interface Generator ()

@property (nonatomic, strong) id<Generatable> generatableObject;

@end

@implementation Generator

#pragma mark - Init

- (instancetype)initWithGeneratableObject:(id<Generatable>)generatable
{
    self = [super init];
    if (self) {
        self.generatableObject = generatable;
    }
    return self;
}

#pragma mark - Private

- (void)createParentServiceResource
{
    NSString *fullFilePathH = [[SettingsManager sharedManager].destinationPath stringByAppendingPathComponent:[[[SettingsManager sharedManager] parentServiceRecourseName] stringByAppendingString:@".h"]];
    NSMutableString *hContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"ParentServicesResource.h"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    [hContentOfFile replaceOccurrencesOfString:CLASS_NAME_MARKER withString:[[SettingsManager sharedManager] parentServiceRecourseName] options:0 range:NSMakeRange(0, hContentOfFile.length)];
    [hContentOfFile replaceOccurrencesOfString:ABSTRACT_SERVER_API_NAME_MARKER withString:[[SettingsManager sharedManager] abstractServerName] options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    [FilesHandler writeString:hContentOfFile toFilePath:fullFilePathH];
    
    NSString *fullFilePathM = [[SettingsManager sharedManager].destinationPath stringByAppendingPathComponent:[[[SettingsManager sharedManager] parentServiceRecourseName] stringByAppendingString:@".m"]];
    NSMutableString *mContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"ParentServicesResource.m"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    [mContentOfFile replaceOccurrencesOfString:CLASS_NAME_MARKER withString:[[SettingsManager sharedManager] parentServiceRecourseName] options:0 range:NSMakeRange(0, hContentOfFile.length)];
    [mContentOfFile replaceOccurrencesOfString:ABSTRACT_SERVER_API_NAME_MARKER withString:[[SettingsManager sharedManager] abstractServerName] options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    [FilesHandler writeString:mContentOfFile toFilePath:fullFilePathM];
}

- (void)createHelperTypes
{
    NSMutableString *objcHtemplate = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"HelperTypesTemplate_h"]
                                                                            encoding:NSUTF8StringEncoding
                                                                               error:nil];
    NSMutableString *objcMtemplate = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"HelperTypesTemplate_m"]
                                                                            encoding:NSUTF8StringEncoding
                                                                               error:nil];
    
    NSString *path = [SettingsManager sharedManager].destinationPath;
    NSString *className = [SettingsManager sharedManager].helperTypesName;
    NSString *prefix = [SettingsManager sharedManager].prefix;
    
    NSString *hFilePath = [[path stringByAppendingPathComponent:className] stringByAppendingString:@".h"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:hFilePath]) {
        [objcHtemplate replaceOccurrencesOfString:PREFIX_NAME_MARKER withString:prefix options:0 range:NSMakeRange(0, objcHtemplate.length)];
        [FilesHandler writeString:objcHtemplate toFilePath:hFilePath];
    }
    
    NSString *mFilePath = [[path stringByAppendingPathComponent:className] stringByAppendingString:@".m"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:mFilePath]) {
        [objcMtemplate replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:[NSString stringWithFormat:@"#import \"%@.h\"", className] options:0 range:NSMakeRange(0, objcMtemplate.length)];
        [objcMtemplate replaceOccurrencesOfString:PREFIX_NAME_MARKER withString:prefix options:0 range:NSMakeRange(0, objcMtemplate.length)];
        [FilesHandler writeString:objcMtemplate toFilePath:mFilePath];
    }
}

- (void)createBaseEntity
{
    NSMutableString *objcHtemplate = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"BaseEntity_h"]
                                                                            encoding:NSUTF8StringEncoding
                                                                               error:nil];
    NSMutableString *objcMtemplate = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"BaseEntity_m"]
                                                                            encoding:NSUTF8StringEncoding
                                                                               error:nil];
    
    NSString *path = [SettingsManager sharedManager].destinationPath;
    NSString *className = [SettingsManager sharedManager].definitionsSuperclassName;
    NSString *prefix = [SettingsManager sharedManager].prefix;
    
    NSString *hFilePath = [[path stringByAppendingPathComponent:className] stringByAppendingString:@".h"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:hFilePath]) {
        [objcHtemplate replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, objcHtemplate.length)];
        
        NSArray<NSString *> *classesToImport = @[[SettingsManager sharedManager].helperTypesName,
                                                 [SettingsManager sharedManager].enumsClassName];
        NSMutableString *importsString = [[NSMutableString alloc] init];
        [classesToImport enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [importsString appendFormat:@"#import \"%@.h\"\n", obj];
        }];
        
        [objcHtemplate replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:importsString options:0 range:NSMakeRange(0, objcHtemplate.length)];
        [FilesHandler writeString:objcHtemplate toFilePath:hFilePath];
    }
    
    NSString *mFilePath = [[path stringByAppendingPathComponent:className] stringByAppendingString:@".m"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:mFilePath]) {
        [objcMtemplate replaceOccurrencesOfString:ENUM_CLASS_NAME_MARKER withString:[[SettingsManager sharedManager] enumsClassName] options:0 range:NSMakeRange(0, objcMtemplate.length)];
        [objcMtemplate replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, objcMtemplate.length)];
        [objcMtemplate replaceOccurrencesOfString:PREFIX_NAME_MARKER withString:prefix options:0 range:NSMakeRange(0, objcMtemplate.length)];
        [FilesHandler writeString:objcMtemplate toFilePath:mFilePath];
    }
}

- (void)generateServicesClasses
{
    NSDictionary<NSString *,NSArray<id<GeneratablePath>> *> *pathsByResources = [self.generatableObject pathsByServiceNames];
    
    NSMutableString *apiFileContent = [[NSMutableString alloc] initWithString:[self serverPathsConstants]];
    
    NSMutableString *abstractServerContent_H_fileContent = [NSMutableString new];
    NSMutableString *abstractServerClassDerectiveDeclaration_H_Content = [NSMutableString new];
    NSMutableString *abstractServerClassIvarsDeclaration_H_Content = [[NSMutableString alloc] initWithString:@"\t@protected\n"];
    
    NSMutableString *abstractServerContent_M_fileContent = [NSMutableString new];
    NSMutableString *abstractServerImports_M_fileContent = [NSMutableString new];
    
    NSMutableArray *sortedResourcesNames = [[pathsByResources allKeys] mutableCopy];
    [sortedResourcesNames sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    for (NSString *resourceName in sortedResourcesNames) {
        NSMutableArray<id<GeneratablePath>> *sortedPaths = [pathsByResources[resourceName] mutableCopy];
        
        [sortedPaths sortUsingComparator:^NSComparisonResult( id<GeneratablePath> _Nonnull obj1, id<GeneratablePath> _Nonnull obj2) {
            if ([obj1 respondsToSelector:@selector(sortableKey)] && [obj2 respondsToSelector:@selector(sortableKey)]) {
                return [[obj1 sortableKey] compare:[obj2 sortableKey] options:NSCaseInsensitiveSearch];
            }
            return [[obj1 methodDeclarationName] compare:[obj2 methodDeclarationName] options:NSCaseInsensitiveSearch];
        }];
        
        NSString *resorceClassName = [self generateH_FileForResourceName:resourceName withPaths:sortedPaths];
        [self generateM_FileForResourceName:resourceName withPaths:sortedPaths];
        
        [apiFileContent setString:[NSString stringWithFormat:@"%@\n%@", apiFileContent, [self APIFileCodeForResourceName:resourceName withPaths:sortedPaths]]];
        [abstractServerContent_H_fileContent setString:[NSString stringWithFormat:@"%@ %@", abstractServerContent_H_fileContent, [self abstractServerDefinitionForResourceName:resourceName andResourceClassName:resorceClassName]]];
        [abstractServerClassDerectiveDeclaration_H_Content setString:[NSString stringWithFormat:@"%@@class %@;\n", abstractServerClassDerectiveDeclaration_H_Content,resorceClassName]];
        [abstractServerClassIvarsDeclaration_H_Content appendFormat:@"\t%@ *_%@;\n", resorceClassName, resourceName];
        
        [abstractServerContent_M_fileContent setString:[NSString stringWithFormat:@"%@ %@", abstractServerContent_M_fileContent, [self abstractServerImplementationForResourceName:resourceName andResourceClassName:resorceClassName]]];
        [abstractServerImports_M_fileContent setString:[NSString stringWithFormat:@"%@#import \"%@.h\"\n", abstractServerImports_M_fileContent, resorceClassName]];
    }
    
    [self generateAPIConstantsFileWithContent:apiFileContent];
    [self generateAbstractServerFile_H_WithContent:abstractServerContent_H_fileContent withClassesDerectiveDeclaration:abstractServerClassDerectiveDeclaration_H_Content andIvarsDeclaration:abstractServerClassIvarsDeclaration_H_Content];
    [self generateAbstractServerFile_M_WithContent:abstractServerContent_M_fileContent withImports:abstractServerImports_M_fileContent];
}

#pragma mark - Resources

- (NSString *)generateH_FileForResourceName:(NSString*)resourceName withPaths:(NSArray<id<GeneratablePath>> *)paths
{
    NSString *className = [NSString stringWithFormat:@"%@%@ServiceResource", [SettingsManager sharedManager].prefix, [resourceName capitalizeFirstCharacter]];
    NSString *resourcesDirectory = [[SettingsManager sharedManager].destinationPath stringByAppendingPathComponent:@"Resources"];
    [FilesHandler createDirectoryForPathIfNeeded:resourcesDirectory];
    
    NSString *fullFilePath = [[resourcesDirectory stringByAppendingPathComponent:className] stringByAppendingString:@".h"];
    
    NSMutableString *hContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"ObjectiveCClassTemplate.h"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    [hContentOfFile insertString:@"//! DO NOT MODIFY THIS CLASS !\n" atIndex:0];
    
    //Generate Class name
    [hContentOfFile replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    NSMutableString *methodsDeclarationString = [NSMutableString new];
    NSMutableSet<NSString *> *customClassesNames = [NSMutableSet new];
    
    
    [paths enumerateObjectsUsingBlock:^(id<GeneratablePath>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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

- (void)generateM_FileForResourceName:(NSString*)resourceName withPaths:(NSArray<id<GeneratablePath>> *)paths
{
    NSString *className = [NSString stringWithFormat:@"%@%@ServiceResource", [SettingsManager sharedManager].prefix, [resourceName capitalizeFirstCharacter]];
    NSString *resourcesDirectory = [[SettingsManager sharedManager].destinationPath stringByAppendingPathComponent:@"Resources"];
    [FilesHandler createDirectoryForPathIfNeeded:resourcesDirectory];
    
    NSString *fullFilePath = [[resourcesDirectory stringByAppendingPathComponent:className] stringByAppendingString:@".m"];
    
    NSMutableString *mContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"ObjectiveCClassTemplate.m"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    [mContentOfFile insertString:@"//! DO NOT MODIFY THIS CLASS !\n" atIndex:0];
    
    //Import Api Const
    [mContentOfFile replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:[NSString stringWithFormat:@"#import \"%@.h\"", [[SettingsManager sharedManager] apiConstantName]] options:0 range:NSMakeRange(0, mContentOfFile.length)];
    
    //Generate Class name
    [mContentOfFile replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, mContentOfFile.length)];
    
    NSMutableString *methodsImplementationString = [NSMutableString new];
    
    [paths enumerateObjectsUsingBlock:^(id<GeneratablePath>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [methodsImplementationString appendFormat:@"%@\n", [obj methodImplementation]];
    }];
    
    [mContentOfFile replaceOccurrencesOfString:CLASS_IMPLEMENTATION_MARKER withString:methodsImplementationString options:0 range:NSMakeRange(0, mContentOfFile.length)];
    
    [FilesHandler writeString:mContentOfFile toFilePath:fullFilePath];
}

#pragma mark - API

- (NSString *)APIFileCodeForResourceName:(NSString*)serviceName withPaths:(NSArray<id<GeneratablePath>> *)paths
{
    NSMutableString *content = [[NSMutableString alloc] initWithFormat:@"#pragma mark - %@ Resource\n", [serviceName capitalizeFirstCharacter]];
    NSMutableSet<NSString*> *addedPathVars = [NSMutableSet new];
    [paths enumerateObjectsUsingBlock:^(id<GeneratablePath>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *varName = [obj apiConstVariableName];
        if (![addedPathVars containsObject:varName]) {
            [content appendFormat:@"static NSString *const %@ = @\"%@\";\n", varName, obj.pathString];
            [addedPathVars addObject:varName];
        }
    }];
    return content;
}

#pragma mark - Server Description

- (NSString *)serverPathsConstants
{
    if (![self.generatableObject respondsToSelector:@selector(serversURLByDescription)]) {
        return @"";
    }
    NSMutableString *result = [NSMutableString new];
    NSMutableArray *sortedKeys = [[[self.generatableObject serversURLByDescription] allKeys] mutableCopy];
    [sortedKeys sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    if (sortedKeys.count > 0) {
        [result appendString:@"\n#pragma mark - Generated Server Paths\n"];
    }
    
    for (NSString *key in sortedKeys) {
        NSString *value = [self.generatableObject serversURLByDescription][key];
        NSString *constantName = [NSString stringWithFormat:@"k %@ Path", key];
        [result appendFormat:@"static NSString *const %@ = @\"%@\";\n", [constantName camelCaseStyleSting], value];
    }
    return result;
}

#pragma mark - Abstract Server

- (NSString *)abstractServerDefinitionForResourceName:(NSString*)resourceName andResourceClassName:(NSString*)resourceClassName
{
    NSString *propertyDefinition = [NSString stringWithFormat:@"@property (nonatomic, readonly) %@ *%@;", resourceClassName, resourceName];
    NSString *methodDefinition = [NSString stringWithFormat:@"+ (%@ *)%@;", resourceClassName, resourceName];
    return [NSString stringWithFormat:@"\n%@\n%@\n", propertyDefinition, methodDefinition];
}

- (NSString *)abstractServerImplementationForResourceName:(NSString*)resourceName andResourceClassName:(NSString*)resourceClassName
{
    NSString *classMethodImplementation = [NSString stringWithFormat:@"+ (%@ *)%@\n{\n\treturn [[%@ sharedServerAPI] %@];\n}\n", resourceClassName, resourceName, [[SettingsManager sharedManager] abstractServerName], resourceName];
    NSString *instanseMethodImplementation = [NSString stringWithFormat:@"- (%@ *)%@\n{\n\tif(!_%@) _%@ = [[%@ alloc] initWithServerAPI:self.child];\n\treturn _%@;\n}", resourceClassName, resourceName, resourceName, resourceName, resourceClassName, resourceName];
    return [NSString stringWithFormat:@"\n%@\n%@\n", classMethodImplementation, instanseMethodImplementation];
}

#pragma mark - APIConst

- (void)generateAPIConstantsFileWithContent:(NSString*)content
{
    NSString *fullFilePath = [[[SettingsManager sharedManager].destinationPath stringByAppendingPathComponent:[[SettingsManager sharedManager] apiConstantName]] stringByAppendingString:@".h"];
    
    NSString *startMarker = @"\n//DO NOT MODIFY THIS CLASS \n#pragma mark - Generated Services Start";
    NSString *endMarker = @"#pragma mark - Generated Services End";
    
    NSString *finalContent = [NSString stringWithFormat:@"%@\n%@\n%@", startMarker, content, endMarker];
    
    [FilesHandler writeString:finalContent toFilePath:fullFilePath];
}

#pragma mark - Server API

- (void)generateAbstractServerFile_H_WithContent:(NSString*)content withClassesDerectiveDeclaration:(NSString*)classesDeclaration andIvarsDeclaration:(NSString*)ivarsDeclaration
{
    NSString *fullFilePath = [[[SettingsManager sharedManager].destinationPath stringByAppendingPathComponent:[[SettingsManager sharedManager] abstractServerName]] stringByAppendingString:@".h"];
    
    NSMutableString *hContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"AbstractServerAPI.h"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    [hContentOfFile replaceOccurrencesOfString:CLASS_NAME_MARKER withString:[[SettingsManager sharedManager] abstractServerName] options:0 range:NSMakeRange(0, hContentOfFile.length)];
    [hContentOfFile replaceOccurrencesOfString:CLASS_DECLARATION_MARKER withString:content options:0 range:NSMakeRange(0, hContentOfFile.length)];
    [hContentOfFile replaceOccurrencesOfString:CLASS_DERECTIVE_DECLARATION_MARKER withString:classesDeclaration options:0 range:NSMakeRange(0, hContentOfFile.length)];
    [hContentOfFile replaceOccurrencesOfString:PARENT_SERVICE_RESOURCE_MARKER withString:[[SettingsManager sharedManager] parentServiceRecourseName] options:0 range:NSMakeRange(0, hContentOfFile.length)];
    [hContentOfFile replaceOccurrencesOfString:CLASS_IVAR_DECLARATION withString:ivarsDeclaration options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    [FilesHandler writeString:hContentOfFile toFilePath:fullFilePath];
}

- (void)generateAbstractServerFile_M_WithContent:(NSString*)content withImports:(NSString*)importsContent
{
    NSString *fullFilePath = [[[SettingsManager sharedManager].destinationPath stringByAppendingPathComponent:[[SettingsManager sharedManager] abstractServerName]] stringByAppendingString:@".m"];
    
    NSMutableString *contentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"AbstractServerAPI.m"]
                                                                            encoding:NSUTF8StringEncoding
                                                                               error:nil];
    [contentOfFile replaceOccurrencesOfString:CLASS_NAME_MARKER withString:[[SettingsManager sharedManager] abstractServerName] options:0 range:NSMakeRange(0, contentOfFile.length)];
    [contentOfFile replaceOccurrencesOfString:CLASS_IMPLEMENTATION_MARKER withString:content options:0 range:NSMakeRange(0, contentOfFile.length)];
    [contentOfFile replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:importsContent options:0 range:NSMakeRange(0, contentOfFile.length)];
    
    [FilesHandler writeString:contentOfFile toFilePath:fullFilePath];
}

#pragma mark - DTO

- (void)generateDTOs
{
    NSString *pathToDefinitionDir = [[SettingsManager sharedManager].destinationPath stringByAppendingPathComponent:@"Schemas"];
    NSString *pathToMachineDirectory = [pathToDefinitionDir stringByAppendingPathComponent:@"Machine"];
    [FilesHandler createDirectoryForPathIfNeeded:pathToMachineDirectory];
    [FilesHandler clearFilesInDirectoryPath:pathToMachineDirectory];
    
    NSString *pathToHumanDirectory = [pathToDefinitionDir stringByAppendingPathComponent:@"Human"];
    [FilesHandler createDirectoryForPathIfNeeded:pathToHumanDirectory];
    
    [[self.generatableObject allGeneratableDTO] enumerateObjectsUsingBlock:^(id<GeneratableDTO>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *machineH_Path = [[pathToMachineDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"_%@", [obj className]]] stringByAppendingString:@".h"];
        NSString *machineM_path = [[pathToMachineDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"_%@", [obj className]]] stringByAppendingString:@".m"];
        
        [FilesHandler writeString:obj.machineClassDeclaration toFilePath:machineH_Path];
        [FilesHandler writeString:obj.machineClassImplementation toFilePath:machineM_path];
        
        NSString *humanH_Path = [[pathToHumanDirectory stringByAppendingPathComponent:[obj className]] stringByAppendingString:@".h"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:humanH_Path]) {
            [FilesHandler writeString:obj.humanClassDeclaration toFilePath:humanH_Path];
        }
        
        NSString *humanM_Path = [[pathToHumanDirectory stringByAppendingPathComponent:[obj className]] stringByAppendingString:@".m"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:humanM_Path]) {
            [FilesHandler writeString:obj.humanClassImplementation toFilePath:humanM_Path];
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
    
    NSDictionary<NSString *,NSArray<NSString *> *> *enumsNamesByOptions = [self.generatableObject enumsNamesByOptions];
    NSMutableArray<NSString *> *sortedEnumsNames = [[enumsNamesByOptions allKeys] mutableCopy];
    [sortedEnumsNames sortUsingSelector:@selector(caseInsensitiveCompare:)];
    
    [sortedEnumsNames enumerateObjectsUsingBlock:^(NSString * _Nonnull name, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSArray<NSString *> *options = enumsNamesByOptions[name];
        
        NSMutableString *h_enumDeclaration = [[NSMutableString alloc] init];
        NSMutableString *h_constantsDeclaration = [[NSMutableString alloc] init];
        
        [h_enumDeclaration appendFormat:@"\ntypedef NS_ENUM(NSUInteger, %@) {\n", enumTypeNameByParameterName(name)];
        [h_constantsDeclaration appendFormat:@"static NSString *const %@ = @\"%@\";\n", enumTypeNameConstantNameByParameterName(name), enumTypeNameByParameterName(name)];
        [h_constantsDeclaration appendFormat:@"static NSUInteger const k%@Count = %zd;\n", enumTypeNameByParameterName(name), options.count];
        
        [m_implementationSection appendFormat:@"\n+ (NSDictionary<NSString *, NSNumber *> *)%@Dictionary\n{\n", enumTypeNameByParameterName(name)];
        [m_implementationSection appendString:@"\tNSMutableDictionary<NSString *, NSNumber *> *dictionary = [NSMutableDictionary new];\n"];
        
        [options enumerateObjectsUsingBlock:^(NSString * _Nonnull enumValue, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                [h_enumDeclaration appendFormat:@"\t%@ = 1", enumValueName(enumTypeNameByParameterName(name), enumValue)];
            } else {
                [h_enumDeclaration appendFormat:@",\n\t%@", enumValueName(enumTypeNameByParameterName(name), enumValue)];
            }
            
            NSString *constVarName = [NSString stringWithFormat:@"k%@String", enumValueName(enumTypeNameByParameterName(name), enumValue)];
            [h_constantsDeclaration appendFormat:@"static NSString *const %@ = @\"%@\";\n", constVarName, enumValue];
            
            [m_implementationSection appendFormat:@"\tdictionary[%@] = @(%zd);\n", constVarName, idx+1];
        }];
        [h_enumDeclaration appendString:@"\n};\n"];
        [h_importSection appendFormat:@"%@\n%@", h_enumDeclaration, h_constantsDeclaration];
        
        [m_implementationSection appendString:@"\treturn [dictionary copy];\n}\n"];
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

#pragma mark - Public

- (void)start
{
    [self createParentServiceResource];
    [self createHelperTypes];
    [self createBaseEntity];
    
    [self generateDTOs];
    [self generateEnumsClass];
    
    [self generateServicesClasses];
}

@end
