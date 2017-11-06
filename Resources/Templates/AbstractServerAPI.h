//! DO NOT MODIFY THIS CLASS !

#import <Foundation/Foundation.h>

@protocol ServerAPIInheritor <NSObject>

- (NSURLSessionTask *)makeRequestWithHTTPMethod:(NSString *)httpMethod
                                       resource:(ParentServicesResource *)resource
                                     forURLPath:(NSString *)urlPath
                                     parameters:(NSDictionary<NSString*, id> *)parameters
                                    outputClass:(Class)outputClass
                                  responseBlock:(void (^)(id, NSError *))responseBlock;

@end

<class_derective_declaration_marker>

@interface <class_name_marker> : NSObject
{
//@protected
//<services_ivars>
}

+ (instancetype)sharedServerAPI;

#pragma mark - Generated services

<class_declaration_marker>

@end

