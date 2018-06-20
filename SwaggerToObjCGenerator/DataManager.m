//
//  DataManager.m
//  SwaggerToObjCGenerator
//
//  Created by Andrey Durbalo on 6/15/18.
//  Copyright © 2018 TMW. All rights reserved.
//

#import "DataManager.h"
#import "Schema.h"
#import "OASchema.h"

@interface DataManager ()

@property (nonatomic, strong) NSMutableArray<OASchema *> *oaSchemas;
@property (nonatomic, strong) NSMutableArray<Schema *> *schemas;

@end

@implementation DataManager

+ (instancetype)sharedManager
{
    static DataManager *instanse = nil;
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
        self.oaSchemas = [NSMutableArray new];
        self.schemas = [NSMutableArray new];
    }
    return self;
}

#pragma mark - Public

- (void)addOASchemas:(NSArray<OASchema *> *)schemas
{
    if (schemas.count == 0) {
        return;
    }
    [self.oaSchemas addObjectsFromArray:schemas];
}

- (OASchema *)oaSchemaByName:(NSString *)name
{
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(OAProperty * _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
        return [name hasSuffix:evaluatedObject.name];
    }];
    OASchema *schema = [[self.oaSchemas filteredArrayUsingPredicate:predicate] firstObject];
    return schema;
}





- (void)addSchemas:(NSArray<Schema *> *)schemas
{
    if (schemas.count == 0) {
        return;
    }
    [self.schemas addObjectsFromArray:schemas];
}

@end
