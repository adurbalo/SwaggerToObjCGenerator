//
//  Protocols.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/12/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#ifndef Protocols_h
#define Protocols_h

@class GeneratablePath, GeneratableDTO;
@protocol GeneratableDTO, GeneratablePath;

@protocol Generatable <NSObject>

- (NSDictionary<NSString*, NSArray< id<GeneratablePath> > *> *)pathsByServiceNames;
- (NSArray< id<GeneratableDTO> > *)allGeneratableDTO;
- (NSDictionary<NSString *, NSArray<NSString *> *> *)enumsNamesByOptions;

@end

@protocol GeneratableDTO <NSObject>

@required
- (NSString *)className;
- (NSString *)humanClassDeclaration;
- (NSString *)humanClassImplementation;
- (NSString *)machineClassDeclaration;
- (NSString *)machineClassImplementation;

@end

@protocol GeneratablePath <NSObject>

@required
- (NSString *)pathString;
- (NSString *)apiConstVariableName;
- (NSString *)methodDeclarationName;
- (NSString *)methodImplementation;
- (NSSet<NSString *> *)customClassesNames;

@end

#endif /* Protocols_h */
