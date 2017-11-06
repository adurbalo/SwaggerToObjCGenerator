//
//  Definition.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/1/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "Definition.h"
#import "Constants.h"

@implementation Definition

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    NSMutableDictionary *keyPathDict = [NSMutableDictionary dictionaryWithDictionary:[super JSONKeyPathsByPropertyKey]];
    [keyPathDict setObject:@"type" forKey:@"type"];
    [keyPathDict setObject:@"required" forKey:@"required"];
    [keyPathDict setObject:@"properties" forKey:@"properties"];
    return keyPathDict;
}

+ (NSValueTransformer *)propertiesJSONTransformer {
    return [MTLValueTransformer transformerUsingForwardBlock:^id(NSDictionary *value, BOOL *success, NSError *__autoreleasing *error) {
        
        NSMutableArray<Property*> *propertiesArray = [NSMutableArray new];
        
        [value enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key, NSDictionary * _Nonnull obj, BOOL * _Nonnull stop) {
            
            NSError *error = nil;
            Property *response = [MTLJSONAdapter modelOfClass:[Property class]
                                           fromJSONDictionary:obj
                                                        error:&error];
            if (error) {
                *stop = YES;
                *success = NO;
                NSLog(@"Error: %@", error);
            } else {
                response.name = key;
            }
            
            if (response) {
                [propertiesArray addObject:response];
            }
        }];
        return (propertiesArray.count > 0)?propertiesArray:nil;
    }];
}

#pragma mark - Public

- (NSString *)machineDeclarationFromTemplate:(NSString*)templateString
{
    NSMutableString *declaration = [[NSMutableString alloc] initWithString:templateString];
    NSString *className = [NSString stringWithFormat:@"_%@", self.name];
    [declaration replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, declaration.length)];
    [declaration replaceOccurrencesOfString:SUPERCLASS_NAME_MARKER withString:@"NSObject" options:0 range:NSMakeRange(0, declaration.length)];
    
    NSMutableSet<NSString *> *customTypes = [NSMutableSet new];
    NSMutableString *propertiesDeclaration = [NSMutableString new];
    
    [self.properties enumerateObjectsUsingBlock:^(Property * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [propertiesDeclaration appendFormat:@"@property (nonatomic, strong) %@%@;\n", [obj objC_fullTypeName], obj.name];
        
        [[obj allTypes] enumerateObjectsUsingBlock:^(NSString * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
            if (isCustomClassType(type)) {
                [customTypes addObject:type];
            }
        }];
    }];
    
    NSMutableString *imports = [NSMutableString new];
    [customTypes enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        [imports appendFormat:@"#import \"%@.h\"\n", obj];
    }];
    
    [declaration replaceOccurrencesOfString:CLASS_DECLARATION_MARKER withString:propertiesDeclaration options:0 range:NSMakeRange(0, declaration.length)];
    [declaration replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:imports options:0 range:NSMakeRange(0, declaration.length)];
    
    return declaration;
}

- (NSString *)machineImplementationFromTemplate:(NSString *)templateString
{
    NSMutableString *implamentation = [[NSMutableString alloc] initWithString:templateString];
    NSString *className = [NSString stringWithFormat:@"_%@", self.name];
    [implamentation replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, implamentation.length)];
    [implamentation replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:@"" options:0 range:NSMakeRange(0, implamentation.length)];
    [implamentation replaceOccurrencesOfString:CLASS_IMPLEMENTATION_MARKER withString:@"" options:0 range:NSMakeRange(0, implamentation.length)];
    return implamentation;
}

- (NSString *)humanDeclarationFromTemplate:(NSString *)templateString
{
    NSMutableString *declaration = [[NSMutableString alloc] initWithString:templateString];
    NSString *className = self.name;
    [declaration replaceOccurrencesOfString:CLASS_NAME_MARKER withString:className options:0 range:NSMakeRange(0, declaration.length)];
    [declaration replaceOccurrencesOfString:SUPERCLASS_NAME_MARKER withString:[NSString stringWithFormat:@"_%@", className] options:0 range:NSMakeRange(0, declaration.length)];
    [declaration replaceOccurrencesOfString:CLASS_DECLARATION_MARKER withString:@"" options:0 range:NSMakeRange(0, declaration.length)];
    [declaration replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:@"" options:0 range:NSMakeRange(0, declaration.length)];
    return declaration;
}

- (NSString *)humanImplementationFromTemplate:(NSString *)templateString
{
    NSMutableString *implamentation = [[NSMutableString alloc] initWithString:templateString];
    [implamentation replaceOccurrencesOfString:CLASS_NAME_MARKER withString:self.name options:0 range:NSMakeRange(0, implamentation.length)];
    [implamentation replaceOccurrencesOfString:CLASS_IMPORT_MARKER withString:@"" options:0 range:NSMakeRange(0, implamentation.length)];
    [implamentation replaceOccurrencesOfString:CLASS_IMPLEMENTATION_MARKER withString:@"" options:0 range:NSMakeRange(0, implamentation.length)];
    return implamentation;;
}

@end
