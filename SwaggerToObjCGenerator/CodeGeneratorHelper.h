//
//  CodeGeneratorHelper.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/14/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Path;

@interface CodeGeneratorHelper : NSObject

+ (void)generateParentServiceResource;

+ (void)generateAbstractServerFile_H_WithContent:(NSString*)content withClassesDerectiveDeclaration:(NSString*)classesDeclaration andIvarsDeclaration:(NSString*)ivarsDeclaration;
+ (void)generateAbstractServerFile_M_WithContent:(NSString*)content withImports:(NSString*)importsContent;
+ (void)generateBaseEntity;

+ (NSString *)APIFileCodeForResourceName:(NSString*)serviceName withPaths:(NSArray<Path*> *)paths;
+ (NSString *)abstractServerDefinitionForResourceName:(NSString*)resourceName andResourceClassName:(NSString*)resourceClassName;
+ (NSString *)abstractServerImplementationForResourceName:(NSString*)resourceName andResourceClassName:(NSString*)resourceClassName;

+ (void)generateAPIConstantsFileWithContent:(NSString*)content;


@end
