
#import "<class_name_marker>.h"

@interface <class_name_marker> ()

@property (nonatomic, strong) <abstract_server_class_name><ServerAPIInheritor> *serverAPI;

@end

@implementation <class_name_marker>

- (instancetype)initWithServerAPI:(<abstract_server_class_name><ServerAPIInheritor> *)serverAPI
{
    self = [super init];
    if (self) {
        self.serverAPI = serverAPI;
    }
    return self;
}

@end
