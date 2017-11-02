//
//  Path.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 10/31/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "Path.h"

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

- (BOOL)isCustomClassName:(NSString*)className;
{
    if (!className) {
        return NO;
    }
    return ![className hasPrefix:@"NS"] && ![className isEqualToString:@"id"];
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
        if ([self isCustomClassName:obj]) {
            [filteredSet addObject:obj];
        }
    }];
    
    return filteredSet;
}

- (NSArray<PathParameter *> *)queryParameters
{
    NSString *placedIn = @"query";
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PathParameter * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject.placedIn isEqualToString:placedIn];
    }];
    NSArray<PathParameter*> *queryParameters = [self.parameters filteredArrayUsingPredicate:predicate];
    return queryParameters;
}

-(NSArray<PathParameter *> *)bodyParameters
{
    NSString *placedIn = @"body";
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(PathParameter * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [evaluatedObject.placedIn isEqualToString:placedIn];
    }];
    NSArray<PathParameter*> *bodyParameters = [self.parameters filteredArrayUsingPredicate:predicate];
    return bodyParameters;
}

- (NSString *)methodName
{
    NSArray *components = [self.pathString componentsSeparatedByString:@"/"];
    if (components.count == 0) {
        components = @[self.pathString];
    }
    
    NSMutableString *methodTitleString = [[NSMutableString alloc] initWithFormat:@"- (NSURLSessionTask *)%@", self.method];
    [components enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [methodTitleString appendString:[obj capitalizedString]];
    }];
    
    BOOL parametersExists = NO;
    if (self.parameters.count > 0) {
        parametersExists = YES;
        [methodTitleString appendString:@"With"];
    }
    
    [self.parameters enumerateObjectsUsingBlock:^(PathParameter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *name = obj.name;
        if ((name.length > 1) && (idx == 0)) {
            name = [NSString stringWithFormat:@"%@%@", [[name substringToIndex:1] uppercaseString], [name substringFromIndex:1]];
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
    
    // path parameters
    [methodImplementationString appendFormat:@"\tNSString *thePath = @\"%@\";\n", self.pathString];
    
    //Query params
    NSArray<PathParameter*> *queryParameters = [self queryParameters];
    NSString *queryDictionaryInit = @"nil";
    if (queryParameters.count > 0) {
        queryDictionaryInit = @"[[NSMutableDictionary alloc] init]";
    }
    [methodImplementationString appendFormat:@"\tNSMutableDictionary *queryParmeters = %@;\n", queryDictionaryInit];
    [queryParameters enumerateObjectsUsingBlock:^(PathParameter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [methodImplementationString appendFormat:@"\tqueryParmeters[@\"%@\"] = %@;\n", obj.name, obj.name];
    }];
    
    //Body params
    NSArray<PathParameter*> *bodyParameters = [self bodyParameters];
    NSString *bodyDictionaryInit = @"nil";
    if (bodyParameters.count > 0) {
        bodyDictionaryInit = @"[[NSMutableDictionary alloc] init]";
    }
    [methodImplementationString appendFormat:@"\tNSMutableDictionary *bodyParmeters = %@;\n", bodyDictionaryInit];
    [bodyParameters enumerateObjectsUsingBlock:^(PathParameter * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [methodImplementationString appendFormat:@"\tbodyParmeters[@\"%@\"] = %@;\n", obj.name, obj.name];
    }];
    
    [methodImplementationString appendString:@"\n}\n"];
    return methodImplementationString;
}

@end
