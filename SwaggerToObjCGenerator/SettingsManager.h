//
//  SettingsManager.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/7/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Protocols.h"

#define HELP_KEY @"-help"
#define SHORT_HELP_KEY @"-h"

typedef NS_ENUM(NSUInteger, ContentType) {
    ContentTypeJSON,
    ContentTypeYAML,
    ContentTypeUndefined
};

@interface SettingsManager : NSObject

@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *resourcesPath;
@property (nonatomic, strong) NSString *destinationPath;

+ (instancetype)sharedManager;
- (void)configurateWithArgumentsDictionary:(NSDictionary<NSString*, NSString*> *)argumentsDictionary;
- (void)showHelp;

- (id<Generatable>)generator;
- (NSString *)parentServiceRecourseName;
- (NSString *)apiConstantName;
- (NSString *)abstractServerName;
- (NSString *)enumsClassName;
- (NSString *)definitionsSuperclassName;
- (NSString *)typeNameWithType:(NSString *)type;

- (NSDictionary<NSString* ,NSArray<NSString *> *> *)enumsDictionary;
- (void)addEnumName:(NSString *)enumName withOptions:(NSArray<NSString *> *)options;

@property (nonatomic, strong) NSArray *allSchemas;

@end
