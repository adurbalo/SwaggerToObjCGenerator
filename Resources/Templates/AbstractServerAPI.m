//! DO NOT MODIFY THIS CLASS !

#import "<class_name_marker>.h"
<import_marker>

@implementation <class_name_marker>

#pragma mark - Lifecycle

+ (instancetype)sharedServerAPI
{
    static dispatch_once_t once;
    static <class_name_marker> *sharedInstance;
    dispatch_once(&once, ^{
        NSAssert([self conformsToProtocol:@protocol(ServerAPIInheritor)],
                 @"<class_name_marker> is an abstract class. It must be inherited for use. Inheritor must conform to protocol WADLAbstractServerAPI");
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - Generated services

<class_implementation_marker>

- (<class_name_marker><ServerAPIInheritor>*)child
{
    return (<class_name_marker><ServerAPIInheritor>*)self;
}

@end
