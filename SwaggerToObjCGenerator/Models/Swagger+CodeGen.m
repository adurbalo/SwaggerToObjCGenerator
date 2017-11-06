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

@implementation Swagger (CodeGen)

- (NSString *)parentServiceRecourseName
{
    return [NSString stringWithFormat:@"%@ParentServicesResource", self.prefix];
}

- (NSString *)apiConstantName
{
    return [NSString stringWithFormat:@"%@APIConstants", self.prefix];
}

- (NSString *)abstractServerName
{
    return [NSString stringWithFormat:@"%@AbstractServerAPI", self.prefix];
}

- (void)generateObjC_Classes
{
    [self generateParentServiceResource];
    [self generateServicesClasses];
    [self generateDefinitionsClasses];
}

#pragma mark - Preparation

- (void)createDirectoryForPathIfNeeded:(NSString*)path
{
    BOOL isDirectory = NO;
    if (![[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDirectory]) {
        NSError* error;
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        if (error) {
            NSLog(@"Error: %@", error);
        }
    }
}

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
    
    NSMutableString *abstractServerContent_M_fileContent = [NSMutableString new];
    NSMutableString *abstractServerImports_M_fileContent = [NSMutableString new];
    
    [pathsByResources enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull resourceName, NSArray<Path *> * _Nonnull obj, BOOL * _Nonnull stop) {
        
        NSString *resorceClassName = [self generateH_FileForResourceName:resourceName withPaths:obj];
        [self generateM_FileForResourceName:resourceName withPaths:obj];
        
        [apiFileContent setString:[NSString stringWithFormat:@"%@\n%@", apiFileContent, [self APIFileCodeForResourceName:resourceName withPaths:obj]]];
        [abstractServerContent_H_fileContent setString:[NSString stringWithFormat:@"%@ %@", abstractServerContent_H_fileContent, [self abstractServerDefinitionForResourceName:resourceName andResourceClassName:resorceClassName]]];
        [abstractServerClassDerectiveDeclaration_H_Content setString:[NSString stringWithFormat:@"%@@class %@;\n", abstractServerClassDerectiveDeclaration_H_Content,resorceClassName]];
        
        [abstractServerContent_M_fileContent setString:[NSString stringWithFormat:@"%@ %@", abstractServerContent_M_fileContent, [self abstractServerImplementationForResourceName:resourceName andResourceClassName:resorceClassName]]];
        [abstractServerImports_M_fileContent setString:[NSString stringWithFormat:@"%@#import \"%@.h\"\n", abstractServerImports_M_fileContent, resorceClassName]];
    }];
    
    [self generateAPIConstantsFileWithContent:apiFileContent];
    [self generateAbstractServerFile_H_WithContent:abstractServerContent_H_fileContent withClassesDerectiveDeclaration:abstractServerClassDerectiveDeclaration_H_Content];
    [self generateAbstractServerFile_M_WithContent:abstractServerContent_M_fileContent withImports:abstractServerImports_M_fileContent];
}

- (NSString *)APIFileCodeForResourceName:(NSString*)serviceName withPaths:(NSArray<Path*> *)paths
{
    NSMutableString *content = [[NSMutableString alloc] initWithFormat:@"#pragma mark - %@ Resource\n", [serviceName capitalizeFirstCharacter]];
    [paths enumerateObjectsUsingBlock:^(Path * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [content appendFormat:@"static NSString *const %@ = @\"%@\";\n", [obj apiConstVariableName], obj.pathString];
    }];
    return content;
}

- (NSString *)abstractServerDefinitionForResourceName:(NSString*)resourceName andResourceClassName:(NSString*)resourceClassName
{
    NSString *propertyDefinition = [NSString stringWithFormat:@"@property (nonatomic, readonly) %@ *%@;", resourceClassName, resourceName];
    NSString *methodDefinition = [NSString stringWithFormat:@"+ (%@ *)%@;", resourceClassName, resourceName];
    return [NSString stringWithFormat:@"\n%@\n%@\n", propertyDefinition, methodDefinition];
}

- (NSString *)abstractServerImplementationForResourceName:(NSString*)resourceName andResourceClassName:(NSString*)resourceClassName
{
    NSString *classMethodImplementation = [NSString stringWithFormat:@"+ (%@ *)%@\n{\n\treturn [[self sharedServerAPI] %@];\n}\n", resourceClassName, resourceName, resourceName];
    NSString *instanseMethodImplementation = [NSString stringWithFormat:@"- (%@ *)%@\n{\n\tif(!_%@) _%@ = [[%@ alloc] initWithServerAPI:self.child];\n\treturn _%@\n}", resourceClassName, resourceName, resourceName, resourceName, resourceClassName, resourceName];
    return [NSString stringWithFormat:@"\n%@\n%@\n", classMethodImplementation, instanseMethodImplementation];
}

#pragma mark - Generation

- (void)generateParentServiceResource
{
    NSString *fullFilePathH = [self.destinationPath stringByAppendingPathComponent:[[self parentServiceRecourseName] stringByAppendingString:@".h"]];
    NSMutableString *hContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[self.resourcesPath stringByAppendingPathComponent:@"ParentServicesResource.h"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    [hContentOfFile replaceOccurrencesOfString:CLASS_NAME_MARKER withString:[self parentServiceRecourseName] options:0 range:NSMakeRange(0, hContentOfFile.length)];
    [hContentOfFile replaceOccurrencesOfString:ABSTRACT_SERVER_API_NAME_MARKER withString:[self abstractServerName] options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    NSError *hError = nil;
    [hContentOfFile writeToFile:fullFilePathH atomically:YES encoding:NSUTF8StringEncoding error:&hError];
    if (hError) {
        NSLog(@"Error: %@", hError);
    };
    
    NSString *fullFilePathM = [self.destinationPath stringByAppendingPathComponent:[[self parentServiceRecourseName] stringByAppendingString:@".m"]];
    NSMutableString *mContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[self.resourcesPath stringByAppendingPathComponent:@"ParentServicesResource.m"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    [mContentOfFile replaceOccurrencesOfString:CLASS_NAME_MARKER withString:[self parentServiceRecourseName] options:0 range:NSMakeRange(0, hContentOfFile.length)];
    [mContentOfFile replaceOccurrencesOfString:ABSTRACT_SERVER_API_NAME_MARKER withString:[self abstractServerName] options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    NSError *mError = nil;
    [mContentOfFile writeToFile:fullFilePathM atomically:YES encoding:NSUTF8StringEncoding error:&mError];
    if (mError) {
        NSLog(@"Error: %@", mError);
    };
}

- (void)generateAPIConstantsFileWithContent:(NSString*)content
{
    NSString *fullFilePath = [[self.destinationPath stringByAppendingPathComponent:[self apiConstantName]] stringByAppendingString:@".h"];
    
    NSString *startMarker = @"\n//DO NOT MODIFY THIS CLASS \n#pragma mark - Generated Services Start";
    NSString *endMarker = @"#pragma mark - Generated Services End";
    
    NSString *finalContent = [NSString stringWithFormat:@"%@\n%@\n%@", startMarker, content, endMarker];
    
    NSError *error = nil;
    [finalContent writeToFile:fullFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    };
}

- (void)generateAbstractServerFile_H_WithContent:(NSString*)content withClassesDerectiveDeclaration:(NSString*)classesDeclaration
{
    NSString *fullFilePath = [[self.destinationPath stringByAppendingPathComponent:[self abstractServerName]] stringByAppendingString:@".h"];
    
    NSMutableString *hContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[self.resourcesPath stringByAppendingPathComponent:@"AbstractServerAPI.h"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    [hContentOfFile replaceOccurrencesOfString:CLASS_NAME_MARKER withString:[self abstractServerName] options:0 range:NSMakeRange(0, hContentOfFile.length)];
    [hContentOfFile replaceOccurrencesOfString:CLASS_DECLARATION_MARKER withString:content options:0 range:NSMakeRange(0, hContentOfFile.length)];
    [hContentOfFile replaceOccurrencesOfString:CLASS_DERECTIVE_DECLARATION_MARKER withString:classesDeclaration options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    NSError *error = nil;
    [hContentOfFile writeToFile:fullFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    };
}

- (void)generateAbstractServerFile_M_WithContent:(NSString*)content withImports:(NSString*)importsContent
{
    NSString *fullFilePath = [[self.destinationPath stringByAppendingPathComponent:[self abstractServerName]] stringByAppendingString:@".m"];
    
    NSMutableString *hContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[self.resourcesPath stringByAppendingPathComponent:@"AbstractServerAPI.m"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    [hContentOfFile replaceOccurrencesOfString:CLASS_NAME_MARKER withString:[self abstractServerName] options:0 range:NSMakeRange(0, hContentOfFile.length)];
    [hContentOfFile replaceOccurrencesOfString:CLASS_IMPLEMENTATION_MARKER withString:content options:0 range:NSMakeRange(0, hContentOfFile.length)];
    [hContentOfFile replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:importsContent options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    NSError *error = nil;
    [hContentOfFile writeToFile:fullFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    };
}

- (NSString *)generateH_FileForResourceName:(NSString*)resourceName withPaths:(NSArray<Path*> *)paths
{
    NSString *className = [NSString stringWithFormat:@"%@%@ServiceResource", self.prefix, [resourceName capitalizeFirstCharacter]];
    NSString *resourcesDirectory = [self.destinationPath stringByAppendingPathComponent:@"Resources"];
    [self createDirectoryForPathIfNeeded:resourcesDirectory];
    
    NSString *fullFilePath = [[resourcesDirectory stringByAppendingPathComponent:className] stringByAppendingString:@".h"];
    
    NSMutableString *hContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[self.resourcesPath stringByAppendingPathComponent:@"ObjectiveCClassTemplate.h"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    //Generate Class name
    [hContentOfFile replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    NSMutableString *methodsDeclarationString = [NSMutableString new];
    NSMutableSet<NSString *> *customClassesNames = [NSMutableSet new];
    
    
    [paths enumerateObjectsUsingBlock:^(Path * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *methodName = [obj methodName];
        [methodsDeclarationString appendFormat:@"%@;\n", methodName];
        [customClassesNames addObjectsFromArray:[[obj customClassesNames] allObjects]];
    }];
    
    //Generate Methods
    [hContentOfFile replaceOccurrencesOfString:CLASS_DECLARATION_MARKER withString:methodsDeclarationString options:0 range:NSMakeRange(0, hContentOfFile.length)];

    [hContentOfFile replaceOccurrencesOfString:SUPERCLASS_NAME_MARKER withString:[self parentServiceRecourseName] options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    //Generate Imports
    NSMutableString *importsString = [NSMutableString new];
    [customClassesNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [importsString appendFormat:@"#import \"%@.h\"\n", obj];
    }];
    [hContentOfFile replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:importsString options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    NSError *error = nil;
    [hContentOfFile writeToFile:fullFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    };
    return className;
}

- (void)generateM_FileForResourceName:(NSString*)resourceName withPaths:(NSArray<Path*> *)paths
{
    NSString *className = [NSString stringWithFormat:@"%@%@ServiceResource", self.prefix, [resourceName capitalizeFirstCharacter]];
    NSString *resourcesDirectory = [self.destinationPath stringByAppendingPathComponent:@"Resources"];
    [self createDirectoryForPathIfNeeded:resourcesDirectory];
    
    NSString *fullFilePath = [[resourcesDirectory stringByAppendingPathComponent:className] stringByAppendingString:@".m"];
    
    NSMutableString *mContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[self.resourcesPath stringByAppendingPathComponent:@"ObjectiveCClassTemplate.m"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    //Import Api Const
    [mContentOfFile replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:[NSString stringWithFormat:@"#import \"%@.h\"", [self apiConstantName]] options:0 range:NSMakeRange(0, mContentOfFile.length)];
    
    //Generate Class name
    [mContentOfFile replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, mContentOfFile.length)];
    
    NSMutableString *methodsImplementationString = [NSMutableString new];
    
    [paths enumerateObjectsUsingBlock:^(Path * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [methodsImplementationString appendFormat:@"%@\n", [obj methodImplementation]];
    }];
    
    [mContentOfFile replaceOccurrencesOfString:CLASS_IMPLEMENTATION_MARKER withString:methodsImplementationString options:0 range:NSMakeRange(0, mContentOfFile.length)];
    
    NSError *error = nil;
    [mContentOfFile writeToFile:fullFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
    };
}

#pragma mark - Definitions

- (void)generateDefinitionsClasses
{
    NSString *objcHtemplate = [[NSString alloc] initWithContentsOfFile:[self.resourcesPath stringByAppendingPathComponent:@"ObjectiveCClassTemplate.h"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    NSString *objcMtemplate = [[NSString alloc] initWithContentsOfFile:[self.resourcesPath stringByAppendingPathComponent:@"ObjectiveCClassTemplate.m"]
                                                                            encoding:NSUTF8StringEncoding
                                                                               error:nil];
    NSString *pathToDefinitionDir = [self.destinationPath stringByAppendingPathComponent:@"Definitions"];
    NSString *pathToMachineDirectory = [pathToDefinitionDir stringByAppendingPathComponent:@"Machine"];
    [self createDirectoryForPathIfNeeded:pathToMachineDirectory];
    [self clearFilesInDirectoryPath:pathToMachineDirectory];
    
    NSString *pathToHumanDirectory = [pathToDefinitionDir stringByAppendingPathComponent:@"Human"];
    [self createDirectoryForPathIfNeeded:pathToHumanDirectory];
    
    [self.definitions enumerateObjectsUsingBlock:^(Definition * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *machineH_Path = [[pathToMachineDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"_%@", obj.name]] stringByAppendingString:@".h"];
        NSString *machineM_path = [[pathToMachineDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"_%@", obj.name]] stringByAppendingString:@".m"];
        
        [self writeString:[obj machineDeclarationFromTemplate:objcHtemplate] toFilePath:machineH_Path];
        [self writeString:[obj machineImplementationFromTemplate:objcMtemplate] toFilePath:machineM_path];
        
        NSString *humanH_Path = [[pathToHumanDirectory stringByAppendingPathComponent:obj.name] stringByAppendingString:@".h"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:humanH_Path]) {
            [self writeString:[obj humanDeclarationFromTemplate:objcHtemplate] toFilePath:humanH_Path];
        }
        
        NSString *humanM_path = [[pathToHumanDirectory stringByAppendingPathComponent:obj.name] stringByAppendingString:@".m"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:humanM_path]) {
            [self writeString:[obj machineImplementationFromTemplate:objcMtemplate] toFilePath:humanM_path];
        }
    }];
}

- (void)clearFilesInDirectoryPath:(NSString*)path
{
    NSDirectoryEnumerator* en = [[NSFileManager defaultManager] enumeratorAtPath:path];
    NSError* err = nil;
    BOOL res = NO;
    
    NSString* file;
    while (file = [en nextObject]) {
        res = [[NSFileManager defaultManager] removeItemAtPath:[path stringByAppendingPathComponent:file] error:&err];
        if (!res && err) {
            NSLog(@"oops: %@", err);
        }
    }
}

- (void)writeString:(NSString *)contentString toFilePath:(NSString *)filePath
{
    if (!contentString) {
        return;
    }
    
    NSError *error = nil;
    [contentString writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (error) {
        NSLog(@"Error: %@", error);
    };
}

@end
