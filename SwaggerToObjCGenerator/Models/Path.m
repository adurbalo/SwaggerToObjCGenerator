//
//  Path.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 10/31/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "Path.h"
#import "NSString+Helper.h"
#import "Constants.h"
#import "SettingsManager.h"
#import "OASchema.h"

@interface Path ()
 
@end

@implementation Path

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"tags" forKey:@"tags"];
    [keyPathDict setObject:@"summary" forKey:@"summary"];
    [keyPathDict setObject:@"description" forKey:@"pathDescription"];
    [keyPathDict setObject:@"operationId" forKey:@"operationId"];
    [keyPathDict setObject:@"produces" forKey:@"produces"];
    [keyPathDict setObject:@"parameters" forKey:@"parameters"];
    [keyPathDict setObject:@"responses" forKey:@"responses"];
    return keyPathDict;
}

+ (NSValueTransformer *)parametersJSONTransformer {
    return [MTLJSONAdapter arrayTransformerWithModelClass:PathParameter.class];
}

+ (NSValueTransformer *)responsesJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSMutableArray<Response*> *responsesArray = [NSMutableArray new];
        
        [value enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSError *error = nil;
            Response *response = [MTLJSONAdapter modelOfClass:[Response class]
                                           fromJSONDictionary:obj
                                                        error:&error];
            if (error) {
                *stop = YES;
                *success = NO;
                NSLog(@"Error: %@", error);
            } else {
                response.code = [key integerValue];
            }
            
            if (response) {
                [responsesArray addObject:response];
            }
        }];
        return (responsesArray.count > 0)?responsesArray:nil;
    }];
}

#pragma mark - Internal

- (Response *)successResponse
{
    __block Response *response = nil;
    [self.responses enumerateObjectsUsingBlock:^(Response * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.code == 200) {
            response = obj;
            *stop = YES;
        }
    }];
    return response;
}

- (NSArray<NSString *> *)availableParametersTypes
{
    NSArray<NSString *> *types = [self.parameters valueForKeyPath:@"@distinctUnionOfObjects.placedIn"];
    return types;
}

- (NSArray<PathParameter *> *)parametersByPlacedIn:(NSString *)placedIn
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PathParameter * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject.placedIn isEqualToString:placedIn];
    }];
    NSArray<PathParameter*> *queryParameters = [self.parameters filteredArrayUsingPredicate:predicate];
    return queryParameters;
}

- (NSString *)operationName
{
    NSString *description = self.operationId?:self.summary;
    NSString *operationName = [description camelCaseStyleSting];
    if (operationName.length == 0) {
        NSCharacterSet *charactersToRemove = [[NSCharacterSet letterCharacterSet] invertedSet];
        operationName = [[self.method componentsSeparatedByCharactersInSet:charactersToRemove] componentsJoinedByString:@""];
    }
    return operationName;
}

#pragma mark - Public

- (NSSet<NSString *> *)customClassesNames
{
    NSMutableSet<NSString *> *names = [NSMutableSet set];
    
    [self.responses enumerateObjectsUsingBlock:^(Response * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([SettingsManager sharedManager].isOpenAPI) {
            NSString *customName = [obj.content.schema objc_CustomTypeName];
            if (customName) {
                [names addObject:customName];
            }
            if ([obj.content.schema isEnumType]) {
                [names addObject:[[SettingsManager sharedManager] enumsClassName]];
            }
        } else {
            NSArray *allTypes = [obj.schema allTypes];
            if ([allTypes count] > 0) {
                [names addObjectsFromArray:allTypes];
            }
        }
    }];
    
    [self.parameters enumerateObjectsUsingBlock:^(PathParameter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([SettingsManager sharedManager].isOpenAPI) {
            NSString *customName = [obj.oaSchema objc_CustomTypeName];
            if (customName) {
                [names addObject:customName];
            }
            if ([obj.oaSchema isEnumType]) {
                [names addObject:[[SettingsManager sharedManager] enumsClassName]];
            }
        } else {
            NSArray *allTypes = [[obj currentSchema] allTypes];
            if ([allTypes count] > 0) {
                [names addObjectsFromArray:allTypes];
            }
        }
    }];
    
    NSMutableSet<NSString *> *filteredSet = [NSMutableSet new];
    [names enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        if (isCustomClassType(obj)) {
            [filteredSet addObject:obj];
        }
    }];
    
    return filteredSet;
}

- (NSString *)apiConstVariableName
{
    NSArray *components = [self.pathString componentsSeparatedByString:@"/"];
    if (components.count == 0) {
        components = @[self.pathString];
    }
    
    NSMutableString *varNameString = [[NSMutableString alloc] initWithString:@"k"];
    NSCharacterSet *set = [[NSCharacterSet letterCharacterSet] invertedSet];
    [components enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *oneComp = [[obj componentsSeparatedByCharactersInSet:set] componentsJoinedByString:@""];
        if (oneComp.length > 0) {
            [varNameString appendString:[oneComp capitalizeFirstCharacter]];
        }
    }];
    [varNameString appendString:@"APIPath"];
    return [varNameString copy];
}

- (NSString *)methodDeclarationName
{
    return [self methodNameForDeclaration:YES];
}

- (NSString *)methodNameForDeclaration:(BOOL)forDeclaration
{
    NSMutableString *methodTitleString = [[NSMutableString alloc] init];
    NSString *description = nil;
    if (self.summary.length > 0) {
        description = [self.summary copy];
    }
    if (self.pathDescription.length > 0) {
        if (!description) {
            description = [self.pathDescription copy];
        } else {
            description = [description stringByAppendingFormat:@"\n %@", self.pathDescription];
        }
    }
    if (description && forDeclaration) {
        [methodTitleString appendFormat:@"\n%@", [description documentationStyleString]];
    }
    
    [methodTitleString appendFormat:@"- (NSURLSessionTask *)%@", [self operationName]];
    
    BOOL parametersExists = NO;
    if (self.parameters.count > 0) {
        parametersExists = YES;
        [methodTitleString appendString:@"With"];
    }
    
    [self.parameters enumerateObjectsUsingBlock:^(PathParameter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *name = objC_parameterNameFromSwaggerParameter(obj.name);
        NSString *title = [name copy];
        if (idx == 0) {
            title = [title capitalizeFirstCharacter];
        }
        if ([SettingsManager sharedManager].isOpenAPI) {
            [methodTitleString appendFormat:@"%@:(%@)%@ ", title, [obj.oaSchema objc_FullTypeName], name];
        } else {
            [methodTitleString appendFormat:@"%@:(%@)%@ ", title, [[obj currentSchema] objC_fullTypeName], name];
        }
    }];
    
    if (parametersExists) {
        [methodTitleString appendString:@"and"];
    }
    
    Response *response = [self successResponse];
    
    if (response.content) { //OpenAPI
        
        [methodTitleString appendFormat:@"ResponseBlock:(void(^)(%@response, NSError *error))responseBlock", [response.content.schema objc_FullTypeName]];
            
    } else if (response.schema) { //Swagger
        [methodTitleString appendFormat:@"ResponseBlock:(void(^)(%@response, NSError *error))responseBlock", [response.schema objC_fullTypeName]];
    } else {
        [methodTitleString appendString:@"ResponseBlock:(void(^)(id response, NSError *error))responseBlock"];
    }
    return methodTitleString;
}

- (NSString *)methodImplementation
{
    NSMutableString *methodImplementationString = [NSMutableString new];
    NSString *methodName = [self methodNameForDeclaration:NO];
    [methodImplementationString appendFormat:@"%@\n{\n", methodName];
    [methodImplementationString appendFormat:@"\tNSString *thePath = [%@ copy];", [self apiConstVariableName]];
    
    NSMutableArray<NSString *> *parameters = [[self availableParametersTypes] mutableCopy];
    NSString *pathParameterName = @"path";
    NSString *bodyParameterName = @"body";

    if ([parameters containsObject:pathParameterName]) {
        [parameters replaceObjectAtIndex:[parameters indexOfObject:pathParameterName] withObject:[parameters firstObject]];
    }
    
    if ([parameters containsObject:bodyParameterName]) {
        [parameters replaceObjectAtIndex:[parameters indexOfObject:bodyParameterName] withObject:[parameters lastObject]];
    }
    
    [parameters enumerateObjectsUsingBlock:^(NSString * _Nonnull parameterType, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if ([parameterType isEqualToString:bodyParameterName]) {
            return;
        }
        
        NSString *variableName = [NSString stringWithFormat:@"%@Parameters", parameterType];
        
        if (![parameterType isEqualToString:pathParameterName]) {
            [methodImplementationString appendFormat:@"\n\tNSMutableDictionary *%@ = [[NSMutableDictionary alloc] init];", variableName];
        } else {
            [methodImplementationString appendFormat:@"\n\tNSArray *pathComponents = [thePath componentsSeparatedByString:@\"/\"];\n\tNSMutableArray *updatedPathComponents = [pathComponents mutableCopy];\n\t[pathComponents enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {"];
        }
        [[self parametersByPlacedIn:parameterType] enumerateObjectsUsingBlock:^(PathParameter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            NSString *parameterVariableName = objC_parameterNameFromSwaggerParameter(obj.name);
            if ([parameterType isEqualToString:pathParameterName]) {
                [methodImplementationString appendFormat:@"\n\t\tif ([obj isEqualToString:@\"{%@}\"]) {\n", obj.name];
                if (obj.enumList.count > 0) {
                    [methodImplementationString appendFormat:@"\t\t\tid parameterObject = [%@ objectForEnumValue:%@ enumName:%@]?:@\"(null)\";\n", [[SettingsManager sharedManager] enumsClassName], parameterVariableName, enumTypeNameConstantNameByParameterName(obj.name)];
                } else {
                    [methodImplementationString appendFormat:@"\t\t\tid parameterObject = %@?:@\"(null)\";\n", parameterVariableName];
                }
                 [methodImplementationString appendString:@"\t\t\t[updatedPathComponents replaceObjectAtIndex:idx withObject:parameterObject];\n\t\t}"];
            } else {
                
                if ([[SettingsManager sharedManager] isOpenAPI]) {
                    if (obj.oaSchema.isEnumType) {
                        [methodImplementationString appendFormat:@"\n\t%@[@\"%@\"] = [%@ objectForEnumValue:%@ enumName:%@];", variableName, obj.name, [[SettingsManager sharedManager] enumsClassName], parameterVariableName, [obj.oaSchema enumTypeConstantName]];
                    } else {
                        
                        if ([obj.oaSchema isDateType]) {
                            [methodImplementationString appendFormat:@"\n\t%@[@\"%@\"] = [%@ stringValue];", variableName, obj.name, parameterVariableName];
                        }
                        else if ([obj.oaSchema objc_CustomTypeName]) {
                            [methodImplementationString appendFormat:@"\n\t%@[@\"%@\"] = [%@ dictionaryValue];", variableName, obj.name, parameterVariableName];
                        }
                        else {
                            [methodImplementationString appendFormat:@"\n\t%@[@\"%@\"] = %@;", variableName, obj.name, parameterVariableName];
                        }
                    }
                } else {
                    if (obj.enumList.count > 0) {
                        [methodImplementationString appendFormat:@"\n\t%@[@\"%@\"] = [%@ objectForEnumValue:%@ enumName:%@];", variableName, obj.name, [[SettingsManager sharedManager] enumsClassName], parameterVariableName, enumTypeNameConstantNameByParameterName(obj.name)];
                    } else {
                        [methodImplementationString appendFormat:@"\n\t%@[@\"%@\"] = %@;", variableName, obj.name, parameterVariableName];
                    }
                }
            }
        }];
        if ([parameterType isEqualToString:pathParameterName]) {
            [methodImplementationString appendFormat:@"\n\t}]; \n\tthePath = [updatedPathComponents componentsJoinedByString:@\"/\"];"];
        }
    }];
    
    [parameters removeObject:pathParameterName];
    if ([parameters count] == 0) {
        [methodImplementationString appendString:@"\n\tNSMutableDictionary<NSString*, id> *requestParameters = nil;"];
    } else {
        [methodImplementationString appendString:@"\n\tNSMutableDictionary<NSString*, id> *requestParameters = [[NSMutableDictionary alloc] init];"];
        [parameters enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isEqualToString:bodyParameterName]) {
                [methodImplementationString appendFormat:@"\n\trequestParameters[@\"%@\"] = [%@ dictionaryValue];", obj, obj];
            } else {
                [methodImplementationString appendFormat:@"\n\trequestParameters[@\"%@\"] = %@Parameters;", obj, obj];
            }
        }];
    }
    
    //Return
    Response *response = [self successResponse];
    NSString *outputClass = nil;
    if (response.schema) {
        if (response.schema.reference) {
            outputClass = objC_classNameFromSwaggerType([response.schema.reference lastPathComponent]);
        } else if (response.schema.itemsType) {
            outputClass = objC_classNameFromSwaggerType([response.schema.itemsType lastPathComponent]);
        } else if (response.schema.type) {
            outputClass = objC_classNameFromSwaggerType([response.schema.type lastPathComponent]);
        }
    } else if (response.content) {
        if (response.content.contentType) {
            [methodImplementationString appendFormat:@"\n\trequestParameters[@\"Content-Type\"] = @\"%@\";", response.content.contentType];
        }
        outputClass = [response.content.schema targetClassName];
    }
    
    if (outputClass){
        outputClass = [NSString stringWithFormat:@"[%@ class]", outputClass];
    }
    else{
        outputClass = @"Nil";
    }
    [methodImplementationString appendFormat:@"\n\treturn [self.serverAPI makeRequestWithHTTPMethod:@\"%@\" resource:self forURLPath:thePath parameters:[requestParameters copy] outputClass:%@ responseBlock:responseBlock];", self.method, outputClass];
    [methodImplementationString appendString:@"\n}\n"];
    return methodImplementationString;
}

- (NSString *)sortableKey
{
    NSString *key = [self methodNameForDeclaration:NO];
    return key;
}

@end
