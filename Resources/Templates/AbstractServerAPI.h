//! DO NOT MODIFY THIS CLASS !

#import <Foundation/Foundation.h>

@protocol WADLServerAPIInheritor <NSObject>
- (WADLRequestTask)makeRequest:(WADLRequestMethod)method
                      resource:(WADLServicesResource*)resource
                    forURLPath:(NSString *)urlPath
               queryParameters:(NSDictionary*)queryParameters
                    bodyObject:(NSDictionary*)parameters
          HTTPHeaderParameters:(NSDictionary*)HTTPHeaderParameters
                   outputClass:(Class)outputClass
                     isInvoked:(BOOL)isInvoked
                 responseBlock:(void (^)(id, NSError *))responseBlock;

@end

<services_classes_declaration>

@interface <class_name_marker> : NSObject
{
@protected
<services_ivars>
}

+ (instancetype)sharedServerAPI;

#pragma mark - Generated services

<class_declaration_marker>

@end

