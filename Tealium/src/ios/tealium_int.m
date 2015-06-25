#import "tealium_int.h"
#import <TealiumLibrary/Tealium.h>
#import <Cordova/CDV.h>

@implementation TealiumPg

static NSString * const Tealium_Platform = @"ios_cordova";
static NSString * const Tealium_LibVersion = @"4.1.10c";
static NSString * const Tealium_MobileBaseURL = @"https://tags.tiqcdn.com/utag/%@/%@/%@/mobile.html?%@=%@&%@=%@&%@=%@&%@=%@";

- (void) init: (CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    NSDictionary* arguments;
    NSString* accountName;
    NSString* profileName;
    NSString* environmentName;
    NSDictionary* customData = nil;
	int options;
	
	@try {
	    arguments = [command.arguments objectAtIndex:0];
	    accountName = [arguments objectForKey:@"account"];
	    profileName = [arguments objectForKey:@"profile"];
	    environmentName = [arguments objectForKey:@"environment"];
		
		id disableHTTPSVal = [arguments objectForKey:@"disableHTTPS"];
		id suppressLogsVal = [arguments objectForKey:@"suppressLogs"];
        id disableExceptionHandlingVal = [arguments objectForKey:@"disableExceptionHandling"];
		
		BOOL disableHTTPS = disableHTTPSVal == nil ? NO : [disableHTTPSVal boolValue];
		BOOL suppressLogs = suppressLogsVal == nil ? YES : [suppressLogsVal boolValue];
        BOOL disableExceptionHandling = disableExceptionHandlingVal == nil ? NO : [disableExceptionHandlingVal boolValue];
				
		options = 
			(disableHTTPS ? TLDisableHTTPS : 0) |
			(suppressLogs ? TLSuppressLogs : TLDisplayVerboseLogs) |
			(disableExceptionHandling ? disableExceptionHandling : 0);
        
        // Below functions did not work as regular methods during Cordova build - added inline below
        
        // timestamp
        NSTimeInterval ti = [[NSDate date] timeIntervalSince1970];
        long tiLong = (long)ti;
        NSString *timestamp = [NSString stringWithFormat:@"%li", tiLong];
        
        // mobile url override
        NSString *osVersion         = [[UIDevice currentDevice] systemVersion];
        NSString *mobileURLString = [NSString stringWithFormat:Tealium_MobileBaseURL,accountName, profileName, environmentName, TealiumDSK_Platform, Tealium_Platform,  TealiumDSK_OSVersion, osVersion, TealiumDSK_LibraryVersion, Tealium_LibVersion, TealiumDSK_TimestampUnix, timestamp];
        
        customData = @{TealiumDSK_OverrideUrl : mobileURLString};
			
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
							options: options
                   globalCustomData: customData];
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
        [Tealium trackCallType:eventType customData:eventData object:nil];
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returnString];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}



@end