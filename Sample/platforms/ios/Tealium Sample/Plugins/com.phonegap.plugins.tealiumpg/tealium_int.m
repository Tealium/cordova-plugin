#import "tealium_int.h"
#import <TealiumLibrary/Tealium.h>
#import <Cordova/CDV.h>

@implementation TealiumPg


- (void) init: (CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    NSDictionary* arguments;
    NSString* accountName;
    NSString* profileName;
    NSString* environmentName;
	int options;
	
	@try {
	    arguments = [command.arguments objectAtIndex:0];
	    accountName = [arguments objectForKey:@"account"];
	    profileName = [arguments objectForKey:@"profile"];
	    environmentName = [arguments objectForKey:@"environment"];
		
		id disableHTTPSVal = [arguments objectForKey:@"disableHTTPS"];
		id suppressLogsVal = [arguments objectForKey:@"suppressLogs"];
		id disableLifeCycleTrackVal = [arguments objectForKey:@"disableLifeCycleTrack"];
		
		BOOL disableHTTPS = disableHTTPSVal == nil ? NO : [disableHTTPSVal boolValue];
		BOOL suppressLogs = suppressLogsVal == nil ? YES : [suppressLogsVal boolValue];
		BOOL disableLifeCycleTrack = disableLifeCycleTrackVal == nil ? NO : [disableLifeCycleTrackVal boolValue];
				
		options = 
			(disableHTTPS ? TLDisableHTTPS : 0) |
			(suppressLogs ? TLSuppressLogs : TLDisplayVerboseLogs) |
			(disableLifeCycleTrack ? TLDisableLifecycleTracking : 0);
			
	}
	@catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
	}
    
    if (accountName != nil && [accountName length] > 0) {
        [Tealium initSharedInstance: accountName
                            profile: profileName
                             target: environmentName
							options: options];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Tealium init"];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    
}




-  (void) track:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    NSDictionary* arguments;
    NSString* eventType;
    NSDictionary* eventData;
    NSData *returnData;
    NSString *returnString;
    @try {
        arguments = [command.arguments objectAtIndex:0];
        eventType = [arguments objectForKey:@"eventType"];
        eventData = [arguments objectForKey:@"eventData"];
        returnData = [NSJSONSerialization dataWithJSONObject:eventData options:NSJSONWritingPrettyPrinted error:nil];
        returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    
    if (eventType != nil && [eventType length] > 0) {
        [[Tealium sharedInstance]  track:nil customData:eventData as:eventType];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returnString];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}



@end