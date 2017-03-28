
#import <Cordova/CDV.h>

@interface TealiumPg : CDVPlugin

@property (nonatomic, readonly) NSMutableDictionary * tagBridgeCallbackIds;
-(void) init:(CDVInvokedUrlCommand*)command;
-(void) track:(CDVInvokedUrlCommand*)command;
-(void) trackLifecycle:(CDVInvokedUrlCommand*)command;
-(void) setPersistent:(CDVInvokedUrlCommand*)command;
-(void) setVolatile:(CDVInvokedUrlCommand*)command;
-(void) getVolatile:(CDVInvokedUrlCommand*)command;
-(void) getPersistent:(CDVInvokedUrlCommand*)command;
-(void) addRemoteCommand:(CDVInvokedUrlCommand*)command;
@end