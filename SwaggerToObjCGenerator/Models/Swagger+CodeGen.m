//
//  Swagger+CodeGen.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/2/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "Swagger+CodeGen.h"

@implementation Swagger (CodeGen)

- (void)generateObjC_Classes
{
    [self generateServicesClasses];
    
}

- (void)generateServicesClasses
{
    NSMutableSet<NSString *> *servicesNames = [NSMutableSet new];
    
    [[self.paths allKeys] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *components = [[obj componentsSeparatedByString:@"/"] mutableCopy];
        [components removeObject:@""];
        
        if ([components firstObject]) {
            [servicesNames addObject:[components firstObject]];
        }
    }];
    
    [servicesNames enumerateObjectsUsingBlock:^(NSString * _Nonnull serviceName, BOOL * _Nonnull stop) {
        
        [self generateServicesH_FilesForServiceName:serviceName];
        [self generateServicesM_FilesForServiceName:serviceName];
        
    }];
}

- (void)generateServicesH_FilesForServiceName:(NSString*)serviceName
{
    NSString *className = [NSString stringWithFormat:@"%@%@Service", self.prefix, [serviceName capitalizedString]];
    NSString *fullFilePath = [[self.destinationPath stringByAppendingPathComponent:className] stringByAppendingString:@".h"];
   
    NSMutableString *hContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[self.resourcesPath stringByAppendingPathComponent:@"ServiceTemplate.h"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    //Generate Class name
    [hContentOfFile replaceOccurrencesOfString:@"<service_class_name>" withString:className options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    NSMutableString *methodsDeclarationString = [NSMutableString new];
    NSMutableSet<NSString *> *customClassesNames = [NSMutableSet new];
    
    [self.paths enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<Path *> * _Nonnull paths, BOOL * _Nonnull stop) {
        
        if (![key hasPrefix:[NSString stringWithFormat:@"/%@/", serviceName]]) {
            return;
        }
        
        [paths enumerateObjectsUsingBlock:^(Path * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *methodName = [obj methodName];
            [methodsDeclarationString appendFormat:@"%@;\n", methodName];
            [customClassesNames addObjectsFromArray:[[obj customClassesNames] allObjects]];
        }];
    }];
    
    //Generate Methods
    [hContentOfFile replaceOccurrencesOfString:@"<methods_declaration>" withString:methodsDeclarationString options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    //Generate Imports
    NSMutableString *importsString = [NSMutableString new];
    [customClassesNames enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [importsString appendFormat:@"#import \"%@.h\"\n", obj];
    }];
    [hContentOfFile replaceOccurrencesOfString:@"<import_xsd>" withString:importsString options:0 range:NSMakeRange(0, hContentOfFile.length)];
    
    NSError *error = nil;
    [hContentOfFile writeToFile:fullFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    };
}

- (void)generateServicesM_FilesForServiceName:(NSString*)serviceName
{
    NSString *className = [NSString stringWithFormat:@"%@%@Service", self.prefix, [serviceName capitalizedString]];
    NSString *fullFilePath = [[self.destinationPath stringByAppendingPathComponent:className] stringByAppendingString:@".m"];
    
    NSMutableString *mContentOfFile = [[NSMutableString alloc] initWithContentsOfFile:[self.resourcesPath stringByAppendingPathComponent:@"ServiceTemplate.m"]
                                                                             encoding:NSUTF8StringEncoding
                                                                                error:nil];
    //Generate Class name
    [mContentOfFile replaceOccurrencesOfString:@"<service_class_name>" withString:className options:0 range:NSMakeRange(0, mContentOfFile.length)];
    
    NSMutableString *methodsImplementationString = [NSMutableString new];
    
    [self.paths enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSArray<Path *> * _Nonnull paths, BOOL * _Nonnull stop) {
        
        if (![key hasPrefix:[NSString stringWithFormat:@"/%@/", serviceName]]) {
            return;
        }
        
        [paths enumerateObjectsUsingBlock:^(Path * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [methodsImplementationString appendFormat:@"%@", [obj methodImplementation]];
        }];

    }];
    
    [mContentOfFile replaceOccurrencesOfString:@"<methods_implementation>" withString:methodsImplementationString options:0 range:NSMakeRange(0, mContentOfFile.length)];
    
    NSError *error = nil;
    [mContentOfFile writeToFile:fullFilePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) {
        NSLog(@"Error: %@", error);
    };
    
    /*
    NSMutableString *methodsImplementation = [NSMutableString stringWithCapacity:1024 * 16];
    for (WADLService *oneService in sortedMethods) {
        NSMutableString *oneMethodImplementation =[[oneService objcMethodName] mutableCopy];
        
        // path parameters
        NSString *pathConstName = [NSString stringWithFormat:@"kWADLService%@URLPath", [oneService.parentServiceSection pathName]];
        [oneMethodImplementation appendFormat:@"\n{\n\tNSString *thePath = [NSString stringWithFormat: %@", pathConstName];
        NSArray *pathParameters = oneService.allPathParameters;
        for (WADLServicePathParameter *parameter in pathParameters) {
            [oneMethodImplementation appendFormat:@", %@", parameter.name];
        }
        [oneMethodImplementation appendFormat:@"];\n"];
        
        // query parameters
        NSArray *queryParametes = oneService.queryParameters;
        if ( queryParametes.count ){
            [oneMethodImplementation appendFormat:@"\tNSMutableDictionary *queryParmeters = [NSMutableDictionary dictionaryWithCapacity:%lu];\n", (unsigned long)queryParametes.count];
            for (WADLServicePathParameter *parameter in queryParametes) {
                [oneMethodImplementation appendFormat:@"\t[queryParmeters setValue:%@ forKey:@\"%@\"];\n", parameter.name, parameter.name];
            }
        }
        else{
            [oneMethodImplementation appendFormat:@"\tNSDictionary *queryParmeters = nil;\n"];
        }
        // Body
        if (oneService.requestObjectClass){
            [oneMethodImplementation appendFormat:@"\tNSDictionary *bodyObject = [%@ dictionaryInfo];\n", [oneService.requestObjectClass lowercaseFirstCharacterString]];
        }
        else{
            [oneMethodImplementation appendFormat:@"\tNSDictionary *bodyObject = nil;\n"];
        }
        
        // head parameters
        NSArray *headParametes = oneService.headParameters;
        if ( headParametes.count ){
            [oneMethodImplementation appendFormat:@"\tNSMutableDictionary *headParameters = [NSMutableDictionary dictionaryWithCapacity:%lu];\n", (unsigned long)headParametes.count];
            for (WADLServicePathParameter *parameter in headParametes) {
                NSString *fixedName = [[parameter.name lowercaseFirstCharacterString] stringByReplacingOccurrencesOfString:@"-" withString:@""];
                [oneMethodImplementation appendFormat:@"\t[headParameters setValue:%@ forKey:@\"%@\"];\n", fixedName, parameter.name];
            }
        }
        else {
            [oneMethodImplementation appendFormat:@"\tNSDictionary *headParameters = nil;\n"];
        }
        
        //requestMethod
        NSString *outputClass = oneService.responseObjectClass;
        if (outputClass){
            outputClass = [NSString stringWithFormat:@"[%@ class]", outputClass];
        }
        else{
            outputClass = @"Nil";
        }
        
        [oneMethodImplementation appendFormat:@"\treturn [self.serverAPI makeRequest:WADLRequestMethod%@ resource:self forURLPath:thePath queryParameters:queryParmeters bodyObject:bodyObject HTTPHeaderParameters:headParameters outputClass:%@ isInvoked:NO responseBlock:responseBlock];\n}\n\n", oneService.method, outputClass];
        
        [methodsImplementation appendString:oneMethodImplementation];
    }
    [mContentOfFile replaceOccurrencesOfString:@"<methods_implementation>" withString:methodsImplementation options:0 range:NSMakeRange(0, mContentOfFile.length)];
    
    [mContentOfFile writeToFile:fullPathMPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    if (error) [error terminate];
    printf("%s.h,m; ",[className UTF8String]);
    */
}

@end
