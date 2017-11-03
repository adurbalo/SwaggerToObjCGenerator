//  WADLAbstractServerAPI.m
//  wadl2objc
//

//! DO NOT MODIFY THIS CLASS !

#import "WADLAbstractServerAPI.h"
<import_services>

@implementation <class_name_marker>

#pragma mark - Lifecycle

+ (instancetype)sharedServerAPI
{
    static dispatch_once_t once;
    static WADLAbstractServerAPI *sharedInstance;
    dispatch_once(&once, ^{
        NSAssert([self conformsToProtocol:@protocol(WADLServerAPIInheritor)],
                 @"WADLAbstractServerAPI is an abstract class. It must be inherited for use. Inheritor must conform to protocol WADLAbstractServerAPI");
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Generated services

<services_getters>

- (WADLAbstractServerAPI<WADLServerAPIInheritor>*)child
{
    return (WADLAbstractServerAPI<WADLServerAPIInheritor>*)self;
}

@end
