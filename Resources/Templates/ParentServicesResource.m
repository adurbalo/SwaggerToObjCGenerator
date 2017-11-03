//  <parent_service_resource>.m
//  wadl2objc
//

#import "<class_name_marker>.h"

@interface <class_name_marker> ()

@property (nonatomic, strong) WADLAbstractServerAPI<WADLServerAPIInheritor> *serverAPI;

@end

@implementation <class_name_marker>

- (instancetype)initWithWADLServerAPI:(WADLAbstractServerAPI<WADLServerAPIInheritor> *)serverAPI
{
    self = [super init];
    if (self) {
        self.serverAPI = serverAPI;
    }
    return self;
}

@end
