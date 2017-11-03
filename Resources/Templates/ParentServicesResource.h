
#import <Foundation/Foundation.h>

@interface <class_name_marker> : NSObject

- (instancetype)initWithWADLServerAPI:(WADLAbstractServerAPI<WADLServerAPIInheritor> *)serverAPI;

@property (nonatomic, readonly) WADLAbstractServerAPI<WADLServerAPIInheritor> *serverAPI;

@end
