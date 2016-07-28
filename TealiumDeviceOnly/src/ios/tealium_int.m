#import "tealium_int.h"
#import <Cordova/CDV.h>
@import TealiumIOSLifecycle;

@implementation TealiumPg

static NSString * const Tealium_Platform = @"ios_cordova";
static NSString * const Tealium_LibVersion = @"5.0.3";
static NSString * const Tealium_MobileBaseURL = @"https://tags.tiqcdn.com/utag/%@/%@/%@/mobile.html?%@=%@&%@=%@&%@=%@&%@=%@";

- (void) init: (CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    NSDictionary* arguments;
    NSString* accountName;
    NSString* profileName;
    NSString* environmentName;
    NSString* instanceName;
    NSString* isLifecycleEnabled;
    // Below functions did not work as regular methods during Cordova build - added inline below
    NSTimeInterval ti = [[NSDate date] timeIntervalSince1970];
    long tiLong = (long)ti;
    NSString *timestamp = [NSString stringWithFormat:@"%li", tiLong];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];

	@try {
	    arguments = [command.arguments objectAtIndex:0];
	    accountName = [arguments objectForKey:@"account"];
	    profileName = [arguments objectForKey:@"profile"];
	    environmentName = [arguments objectForKey:@"environment"];
        instanceName = [arguments objectForKey:@"instance"];
        isLifecycleEnabled = [arguments objectForKey:@"isLifecycleEnabled"];
	}
	@catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
	}

    if (accountName == nil || (accountName != nil && [accountName length] == 0)) {
        // account name not valid - set error response
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tealium: Account Name is null or empty. Please provide a valid account name."];
    } else if (instanceName == nil || (instanceName != nil && [instanceName length] == 0)) {
        // instance name not valid - set error response
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tealium: Instance Name is null or empty. Please provide a valid instance name."];
    } else if (profileName == nil || (profileName != nil && [profileName length] == 0)) {
        // profile name not valid - set error response
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tealium: Profile Name is null or empty. Please provide a valid profile name."];
    } else {
        // we got here with syntactically valid account/profilename/instancename - attempt to init Tealium
        // generate mobile.html override string
        NSString *mobileURLString = [NSString stringWithFormat:Tealium_MobileBaseURL, accountName, profileName, environmentName, TEALDataSourceKey_Platform, Tealium_Platform, TEALDataSourceKey_DeviceOSVersion, osVersion, TEALDataSourceKey_LibraryVersion, Tealium_LibVersion, TEALDataSourceKey_TimestampUnix, timestamp];
        // create a new config object
        TEALConfiguration *configuration = [TEALConfiguration configurationWithAccount:accountName
                                                                            profile:profileName
                                                                            environment:environmentName];
        // set override for mobile.html - publish settings and web view
        configuration.overrideTagManagementURL = configuration.overridePublishSettingsURL = mobileURLString;
        // create a new Tealium instance using the instance name passed in
        [Tealium newInstanceForKey:instanceName configuration:configuration];
        // enable lifecycle tracking
        if (![isLifecycleEnabled isEqualToString:@"false"]){
            [[Tealium instanceForKey:instanceName] setLifecycleAutotrackingIsEnabled:YES];
        }
        // set success response - we initialized successfully with no reported errors
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Tealium: Tealium init successful!"];
    }
    
    // send the plugin response - success or failure
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}

-  (void) track:(CDVInvokedUrlCommand*)command {
    CDVPluginResult* pluginResult = nil;
    NSDictionary* arguments;
    NSString* eventType;
    NSString* instanceName;
    NSString* screenTitle;
    NSString* eventId;
    NSDictionary* eventData;
    NSData *returnData;
    NSString *returnString;
    @try {
        arguments = [command.arguments objectAtIndex:0];
        eventType = [arguments objectForKey:@"eventType"];
        eventData = [arguments objectForKey:@"eventData"];
        instanceName = [arguments objectForKey:@"instance"];
        eventId = [eventData objectForKey:@"link_id"];
        screenTitle = [eventData objectForKey:@"screen_title"];
        returnData = [NSJSONSerialization dataWithJSONObject:eventData options:NSJSONWritingPrettyPrinted error:nil];
        returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tealium: One of the arguments provdied to the track command is invalid."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    
    
    if (eventType != nil && [eventType length] > 0) {
        if ([eventType isEqualToString:@"view"]) {
            [[Tealium instanceForKey:instanceName] trackViewWithTitle:screenTitle dataSources:eventData];
        } else if ([eventType isEqualToString:@"link"]) {
            [[Tealium instanceForKey:instanceName] trackEventWithTitle:eventId dataSources:eventData];
        }
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returnString];
    } else {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
    }
    
    [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
}



@end