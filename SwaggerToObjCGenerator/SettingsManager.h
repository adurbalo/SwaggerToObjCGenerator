//
//  SettingsManager.h
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/7/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SettingsManager : NSObject

@property (nonatomic, strong) NSString *prefix;
@property (nonatomic, strong) NSString *resourcesPath;
@property (nonatomic, strong) NSString *destinationPath;

+ (instancetype)sharedManager;

- (NSString *)parentServiceRecourseName;
- (NSString *)apiConstantName;
- (NSString *)abstractServerName;
- (NSString *)enumsClassName;
- (NSString *)definitionsSuperclassName;

- (NSDictionary<NSString* ,NSArray<NSString *> *> *)enumsDictionary;
- (void)addEnumName:(NSString *)enumName withOptions:(NSArray<NSString *> *)options;


@end
