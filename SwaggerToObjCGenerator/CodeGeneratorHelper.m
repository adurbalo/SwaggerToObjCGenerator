//
//  CodeGeneratorHelper.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/14/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "CodeGeneratorHelper.h"
#import "Constants.h"
#import "FilesHandler.h"
#import "Path.h"

@implementation CodeGeneratorHelper

+ (void)generateParentServiceResource
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

#pragma mark - Server API

+ (void)generateAbstractServerFile_H_WithContent:(NSString*)content withClassesDerectiveDeclaration:(NSString*)classesDeclaration andIvarsDeclaration:(NSString*)ivarsDeclaration
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

+ (void)generateAbstractServerFile_M_WithContent:(NSString*)content withImports:(NSString*)importsContent
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

#pragma mark - BaseEntity

+ (void)generateBaseEntity
{
    NSMutableString *objcHtemplate = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"BaseEntity_h"]
                                                                            encoding:NSUTF8StringEncoding
                                                                               error:nil];
    NSMutableString *objcMtemplate = [[NSMutableString alloc] initWithContentsOfFile:[[SettingsManager sharedManager].resourcesPath stringByAppendingPathComponent:@"BaseEntity_m"]
                                                                            encoding:NSUTF8StringEncoding
                                                                               error:nil];
    
    NSString *path = [SettingsManager sharedManager].destinationPath;
    NSString *className = [SettingsManager sharedManager].definitionsSuperclassName;
    NSString *hFilePath = [[path stringByAppendingPathComponent:className] stringByAppendingString:@".h"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:hFilePath]) {
        [objcHtemplate replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, objcHtemplate.length)];
        [objcHtemplate replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:[NSString stringWithFormat:@"#import \"%@.h\"", [SettingsManager sharedManager].enumsClassName] options:0 range:NSMakeRange(0, objcHtemplate.length)];
        [FilesHandler writeString:objcHtemplate toFilePath:hFilePath];
    }
    
    NSString *mFilePath = [[path stringByAppendingPathComponent:className] stringByAppendingString:@".m"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:mFilePath]) {
        [objcMtemplate replaceOccurrencesOfString:ENUM_CLASS_NAME_MARKER withString:[[SettingsManager sharedManager] enumsClassName] options:0 range:NSMakeRange(0, objcMtemplate.length)];
        [objcMtemplate replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, objcMtemplate.length)];
        [FilesHandler writeString:objcMtemplate toFilePath:mFilePath];
    }
}

+ (NSString *)APIFileCodeForResourceName:(NSString*)serviceName withPaths:(NSArray<Path*> *)paths
{
    NSMutableString *content = [[NSMutableString alloc] initWithFormat:@"#pragma mark - %@ Resource\n", [serviceName capitalizeFirstCharacter]];
    NSMutableSet<NSString*> *addedPathVars = [NSMutableSet new];
    [paths enumerateObjectsUsingBlock:^(Path * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *varName = [obj apiConstVariableName];
        if (![addedPathVars containsObject:varName]) {
            [content appendFormat:@"static NSString *const %@ = @\"%@\";\n", varName, obj.pathString];
            [addedPathVars addObject:varName];
        }
    }];
    return content;
}

+ (NSString *)abstractServerDefinitionForResourceName:(NSString*)resourceName andResourceClassName:(NSString*)resourceClassName
{
    NSString *propertyDefinition = [NSString stringWithFormat:@"@property (nonatomic, readonly) %@ *%@;", resourceClassName, resourceName];
    NSString *methodDefinition = [NSString stringWithFormat:@"+ (%@ *)%@;", resourceClassName, resourceName];
    return [NSString stringWithFormat:@"\n%@\n%@\n", propertyDefinition, methodDefinition];
}

+ (NSString *)abstractServerImplementationForResourceName:(NSString*)resourceName andResourceClassName:(NSString*)resourceClassName
{
    NSString *classMethodImplementation = [NSString stringWithFormat:@"+ (%@ *)%@\n{\n\treturn [[%@ sharedServerAPI] %@];\n}\n", resourceClassName, resourceName, [[SettingsManager sharedManager] abstractServerName], resourceName];
    NSString *instanseMethodImplementation = [NSString stringWithFormat:@"- (%@ *)%@\n{\n\tif(!_%@) _%@ = [[%@ alloc] initWithServerAPI:self.child];\n\treturn _%@;\n}", resourceClassName, resourceName, resourceName, resourceName, resourceClassName, resourceName];
    return [NSString stringWithFormat:@"\n%@\n%@\n", classMethodImplementation, instanseMethodImplementation];
}

#pragma mark - API Constants

+ (void)generateAPIConstantsFileWithContent:(NSString*)content
{
    NSString *fullFilePath = [[[SettingsManager sharedManager].destinationPath stringByAppendingPathComponent:[[SettingsManager sharedManager] apiConstantName]] stringByAppendingString:@".h"];
    
    NSString *startMarker = @"\n//DO NOT MODIFY THIS CLASS \n#pragma mark - Generated Services Start";
    NSString *endMarker = @"#pragma mark - Generated Services End";
    
    NSString *finalContent = [NSString stringWithFormat:@"%@\n%@\n%@", startMarker, content, endMarker];
    
    [FilesHandler writeString:finalContent toFilePath:fullFilePath];
}

@end
