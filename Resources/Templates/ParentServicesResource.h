
#import <Foundation/Foundation.h>
#import "<abstract_server_class_name>.h"

@interface <class_name_marker> : NSObject

- (instancetype)initWithServerAPI:(<abstract_server_class_name><ServerAPIInheritor> *)serverAPI;

@property (nonatomic, readonly) <abstract_server_class_name><ServerAPIInheritor> *serverAPI;

@end
