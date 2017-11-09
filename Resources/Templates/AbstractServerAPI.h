//! DO NOT MODIFY THIS CLASS !

#import <Foundation/Foundation.h>

@class <parent_service_resource_marker>;
@protocol ServerAPIInheritor <NSObject>
- (NSURLSessionTask *)makeRequestWithHTTPMethod:(NSString *)httpMethod
                                       resource:(<parent_service_resource_marker> *)resource
                                     forURLPath:(NSString *)urlPath
                                     parameters:(NSDictionary<NSString*, id> *)parameters
                                    outputClass:(Class)outputClass
                                  responseBlock:(void (^)(id, NSError *))responseBlock;
@end

<class_derective_declaration_marker>

@interface <class_name_marker> : NSObject
{
<class_ivar_declaration>
}

+ (instancetype)sharedServerAPI;

#pragma mark - Generated services

<class_declaration_marker>

@end

