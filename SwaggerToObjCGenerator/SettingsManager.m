//
//  SettingsManager.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 11/7/17.
//  Copyright © 2017 TMW. All rights reserved.
//

#import "SettingsManager.h"
#import "Constants.h"

@interface SettingsManager ()

@property (nonatomic, strong) NSMutableDictionary<NSString* , NSArray<NSString *> *> *enumsDictionary;

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
    }
    return self;
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
    return [NSString stringWithFormat:@"%@BaseDefinition", self.prefix];
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
