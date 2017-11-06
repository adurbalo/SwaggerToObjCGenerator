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

#pragma mark - Public

- (NSSet<NSString *> *)customClassesNames
{
    NSMutableSet<NSString *> *names = [NSMutableSet set];
    
    [self.responses enumerateObjectsUsingBlock:^(Response * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSArray *allTypes = [obj.schema allTypes];
        if ([allTypes count] > 0) {
            [names addObjectsFromArray:allTypes];
        }
    }];
    
    [self.parameters enumerateObjectsUsingBlock:^(PathParameter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSArray *allTypes = [[obj currentSchema] allTypes];
        if ([allTypes count] > 0) {
            [names addObjectsFromArray:allTypes];
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
    [components enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *oneComp = [obj stringByReplacingOccurrencesOfString:@"{" withString:@""];
        oneComp = [oneComp stringByReplacingOccurrencesOfString:@"}" withString:@""];
        [varNameString appendString:[oneComp capitalizeFirstCharacter]];
    }];
    [varNameString appendString:@"APIPath"];
    return varNameString;
}

- (NSString *)methodName
{
    NSArray *components = [self.pathString componentsSeparatedByString:@"/"];
    if (components.count == 0) {
        components = @[self.pathString];
    }
    
    NSMutableString *methodTitleString = [[NSMutableString alloc] initWithFormat:@"- (NSURLSessionTask *)%@", self.method];
    [components enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [methodTitleString appendString:[obj capitalizeFirstCharacter]];
    }];
    
    BOOL parametersExists = NO;
    if (self.parameters.count > 0) {
        parametersExists = YES;
        [methodTitleString appendString:@"With"];
    }
    
    [self.parameters enumerateObjectsUsingBlock:^(PathParameter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *name = obj.name;
        if (idx == 0) {
            name = [name capitalizeFirstCharacter];
        }
        [methodTitleString appendFormat:@"%@:(%@)%@ ", name, [[obj currentSchema] objC_fullTypeName], obj.name];
    }];
    
    Response *response = [self successResponse];
    if (response.schema) {
        if (parametersExists) {
            [methodTitleString appendString:@"and"];
        }
        [methodTitleString appendFormat:@"ResponseBlock:(void(^)(%@response, NSError *error))responseBlock", [response.schema objC_fullTypeName]];
    }
    return methodTitleString;
}

- (NSString *)methodImplementation
{
    NSMutableString *methodImplementationString = [NSMutableString new];
    NSString *methodName = [self methodName];
    [methodImplementationString appendFormat:@"%@\n{\n", methodName];
    [methodImplementationString appendFormat:@"\tNSString *thePath = %@;", [self apiConstVariableName]];
    
    NSMutableArray<NSString *> *parameters = [[self availableParametersTypes] mutableCopy];
    NSString *pathParameterName = @"path";
    [parameters enumerateObjectsUsingBlock:^(NSString * _Nonnull parameterType, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [[self parametersByPlacedIn:parameterType] enumerateObjectsUsingBlock:^(PathParameter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            
            if ([parameterType isEqualToString:pathParameterName]) {
                [methodImplementationString appendFormat:@"\n\tthePath = [thePath stringByReplacingOccurrencesOfString:@\"{%@}\" withString:%@];", obj.name, obj.name];
            } else {
                NSString *variableName = [NSString stringWithFormat:@"%@Parmeters", parameterType];
                [methodImplementationString appendFormat:@"\n\tNSMutableDictionary *%@ = [[NSMutableDictionary alloc] init];", variableName];
                [methodImplementationString appendFormat:@"\n\t%@[@\"%@\"] = %@;", variableName, obj.name, obj.name];
            }
        }];
    }];
    
    [parameters removeObject:pathParameterName];
    if ([parameters count] == 0) {
        [methodImplementationString appendString:@"\n\tNSMutableDictionary<NSString*, id> *requestParmeters = nil;"];
    } else {
        [methodImplementationString appendString:@"\n\tNSMutableDictionary<NSString*, id> *requestParmeters = [[NSMutableDictionary alloc] init];"];
        [parameters enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [methodImplementationString appendFormat:@"\n\trequestParmeters[@\"%@\"] = %@Parmeters;", obj, obj];
        }];
    }
    
    //Return
    NSString *outputClass = nil;
    if (outputClass){
        outputClass = [NSString stringWithFormat:@"[%@ class]", outputClass];
    }
    else{
        outputClass = @"Nil";
    }
    [methodImplementationString appendFormat:@"\n\treturn [self.serverAPI makeRequestWithHTTPMethod:@\"%@\" resource:self forURLPath:thePath parameters:requestParmeters outputClass:%@ responseBlock:responseBlock];", self.method, outputClass];
    [methodImplementationString appendString:@"\n}\n"];
    return methodImplementationString;
}

@end
