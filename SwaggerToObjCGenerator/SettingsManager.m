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

#define DESTINATION_PATH_KEY @"-destinationPath"
#define JSON_PATH_KEY @"-jsonPath"
#define JSON_URL_KEY @"-jsonURL"
#define PREFIX_KEY @"-prefix"


@interface SettingsManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString* , NSArray<NSString *> *> *enumsDictionary;
@property (nonatomic, strong) NSString *jsonPath;
@property (nonatomic, strong) NSString *jsonURL;

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
        self.enumsDictionary = [NSMutableDictionary new];
        
        NSBundle *mainBundle = [NSBundle mainBundle];
        self.resourcesPath = [[mainBundle bundlePath] stringByAppendingPathComponent:@"Resources"];
    }
    return self;
}

- (void)configurateWithArgumentsDictionary:(NSDictionary<NSString *,NSString *> *)argumentsDictionary
{
    self.destinationPath = argumentsDictionary[DESTINATION_PATH_KEY];
    self.prefix = argumentsDictionary[PREFIX_KEY]?:@"";
    
    self.jsonPath = argumentsDictionary[JSON_PATH_KEY];
    self.jsonURL = argumentsDictionary[JSON_URL_KEY];
    
    [self validateInputParameters];
}

- (void)showHelp
{
    NSLog(@"Available parameters:\n\n\t-destinationPath path where generator should place files. \n\t-prefix prefix for files. \n\t-jsonPath local path json file. \n\t-jsonURL json file URL.\n\n");
    exit(0);
}

- (void)validateInputParameters
{
    if (![[NSFileManager defaultManager] isWritableFileAtPath:self.destinationPath]) {
        NSError *error = [NSError errorWithLocalizedDescription:@"Please specify valid destionation path"];
        [error terminate];
    }
}

- (NSData *)jsonData
{
    NSURL *jsonURL = nil;
    if (self.jsonURL) {
        jsonURL = [NSURL URLWithString:self.jsonURL];
    }
    
    if (!jsonURL || ![jsonURL scheme] || ![jsonURL host]) {
        
        if ( ![[NSFileManager defaultManager] isReadableFileAtPath:self.jsonPath]) {
            NSError *error = [NSError errorWithLocalizedDescription:@"Please specify URL or local path to .json file using -jsonPath or -jsonURL parameters"];
            [error terminate];
        } else {
            return [NSData dataWithContentsOfFile:self.jsonPath];
        }
    }
    NSLog(@"Downloading json file 🔜");
    return [NSData dataWithContentsOfURL:jsonURL];
}

#pragma mark - Public

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

- (NSString *)definitionsSuperclassName
{
    return [NSString stringWithFormat:@"%@BaseEntity", self.prefix];
}

#pragma mark - Enums

- (void)addEnumName:(NSString *)enumName withOptions:(NSArray<NSString *> *)options
{
    NSString *updatedName = [enumName capitalizeFirstCharacter];
    if (!updatedName) {
        return;
    }
    [self.enumsDictionary setValue:options forKey:updatedName];
}

@end
