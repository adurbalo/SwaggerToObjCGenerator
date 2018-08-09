//
//  SettingsManager.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/7/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "SettingsManager.h"
#import "Constants.h"
#import "NSError+Extension.h"
#import "YAMLSerialization.h"
#import "Swagger.h"
#import "OpenAPI.h"

#define DESTINATION_PATH_KEY @"-destinationPath"
#define PREFIX_KEY @"-prefix"

#define CONTENT_PATH_KEY @"-contentPath"
#define CONTENT_URL_KEY @"-contentURL"

@interface SettingsManager ()
{
    BOOL _openAPI;
}

@end

@implementation SettingsManager

+ (instancetype)sharedManager {
    static SettingsManager *instanse = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instanse = [[self alloc] init];
    });
    return instanse;
}

- (instancetype)init
{
    self = [super init];
    if (self) {        
        NSBundle *mainBundle = [NSBundle mainBundle];
        self.resourcesPath = [[mainBundle bundlePath] stringByAppendingPathComponent:@"Templates"];
    }
    return self;
}

- (void)configurateWithArgumentsDictionary:(NSDictionary<NSString *,NSString *> *)argumentsDictionary
{
    NSString *destinationPath = [NSString pathWithComponents:[argumentsDictionary[DESTINATION_PATH_KEY] componentsSeparatedByString:@"/"]];
    self.destinationPath = argumentsDictionary[DESTINATION_PATH_KEY];
    self.destinationPath = destinationPath;
    self.prefix = argumentsDictionary[PREFIX_KEY]?:@"";
    
    self.contentPath = argumentsDictionary[CONTENT_PATH_KEY];
    self.contentURL = argumentsDictionary[CONTENT_URL_KEY];
    
    [self validateInputParameters];
}

- (void)showHelp
{
    NSLog(@"Available parameters:\n\n\t-destinationPath path where generator should place files. \n\t-prefix prefix for files. \n\t-contentPath local path for content file. \n\t-contentURL URL for content.\n\n");
    exit(0);
}

- (void)validateInputParameters
{
    if (![[NSFileManager defaultManager] isWritableFileAtPath:self.destinationPath]) {
        NSError *error = [NSError errorWithLocalizedDescription:@"Please specify valid destionation path"];
        [error terminate];
    }
}

- (ContentType)contentType
{
    NSString *pathExtension = [self.contentURL pathExtension];
    
    if (pathExtension.length == 0) {
        pathExtension = [self.contentPath pathExtension];
    }
    
    if ([pathExtension isEqualToString:@"json"]) {
        return ContentTypeJSON;
    } else if ([pathExtension isEqualToString:@"yaml"] || [pathExtension isEqualToString:@"yml"]) {
        return ContentTypeYAML;
    }
    
    NSError *unsupportedContentTypeError = [NSError errorWithLocalizedDescription:@"Unsupported content type! Expected .json or .yaml (.yml) file extension"];
    [unsupportedContentTypeError terminate];
    
    return ContentTypeUndefined;
}

- (NSData *)jsonData
{
    NSURL *contentURL = nil;
    if (self.contentURL) {
        contentURL = [NSURL URLWithString:self.contentURL];
    }
    
    if (!contentURL || ![contentURL scheme] || ![contentURL host]) {
        
        if ( ![[NSFileManager defaultManager] isReadableFileAtPath:self.contentPath]) {
            NSError *error = [NSError errorWithLocalizedDescription:@"Please specify URL or local path to .json file using -jsonPath or -jsonURL parameters"];
            [error terminate];
        } else {
            return [NSData dataWithContentsOfFile:self.contentPath];
        }
    }
    NSLog(@"Downloading content file 🔜");
    return [NSData dataWithContentsOfURL:contentURL];
}

- (NSDictionary *)dictionaryWithError:(NSError *__autoreleasing *)error
{
    NSDictionary *result = nil;
    switch (self.contentType) {
        case ContentTypeJSON:
            result = [NSJSONSerialization JSONObjectWithData:[self jsonData] options:NSJSONReadingAllowFragments error:error];
            break;
        case ContentTypeYAML:
        {
            NSInputStream *stream = nil;
            if (self.contentPath) {
                stream = [[NSInputStream alloc] initWithFileAtPath:self.contentPath];
            } else if (self.contentURL) {
                NSURL *url = [NSURL URLWithString:self.contentURL];
                NSData *data = [NSData dataWithContentsOfURL:url];
                stream = [NSInputStream inputStreamWithData:data];
            }
            result = [YAMLSerialization objectWithYAMLStream:stream
                                                     options:kYAMLReadOptionStringScalars
                                                       error:error];
        }
            break;
        default:
            break;
    }
    return result?[result copy]:nil;
}

#pragma mark - Public

- (id<Generatable>)generator
{
    NSError *error = nil;
    NSDictionary *dictionary = [self dictionaryWithError:&error];
    if (error) {
        [error terminate];
        return nil;
    }
    
    id<Generatable> generator = nil;
    
    if (dictionary[@"swagger"]) {
        
        Swagger *swagger = [MTLJSONAdapter modelOfClass:[Swagger class]
                                     fromJSONDictionary:dictionary
                                                  error:&error];
        
        if (error) {
            [error terminate];
        }
        generator = swagger;
        
    } else if (dictionary[@"openapi"]) {
        
        _openAPI = YES;
        
        OpenAPI *openApi = [MTLJSONAdapter modelOfClass:[OpenAPI class]
                                     fromJSONDictionary:dictionary
                                                  error:&error];
        if (error) {
            [error terminate];
        }
        generator = openApi;
    }
    
    return generator;
}

- (BOOL)isOpenAPI
{
    return _openAPI;
}

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

- (NSString *)enumsClassName
{
    return [NSString stringWithFormat:@"%@Enums", self.prefix];
}

- (NSString *)helperTypesName
{
    return [NSString stringWithFormat:@"%@HelperTypes", self.prefix];
}

- (NSString *)definitionsSuperclassName
{
    return [NSString stringWithFormat:@"%@BaseEntity", self.prefix];
}

- (NSString *)typeNameWithType:(NSString *)type
{
    return [NSString stringWithFormat:@"%@%@", self.prefix, type];
}

@end
