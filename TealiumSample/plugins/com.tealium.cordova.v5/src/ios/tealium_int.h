
#import <Cordova/CDV.h>

@interface TealiumPg : CDVPlugin


-(void) init:(CDVInvokedUrlCommand*)command;
-(void) track:(CDVInvokedUrlCommand*)command;
-(void) trackLifecycle:(CDVInvokedUrlCommand*)command;
-(void) setPersistent:(CDVInvokedUrlCommand*)command;
-(void) setVolatile:(CDVInvokedUrlCommand*)command;

@end