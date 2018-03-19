
#import <Cordova/CDV.h>
#import <AdSupport/AdSupport.h>

@interface TealiumPgAdIdentifier : CDVPlugin

-(void) setPersistent:(CDVInvokedUrlCommand*)command;
-(void) setVolatile:(CDVInvokedUrlCommand*)command;
@end
