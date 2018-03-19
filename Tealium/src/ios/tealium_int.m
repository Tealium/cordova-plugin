#import "tealium_int.h"
#import <Cordova/CDV.h>
@import TealiumIOSLifecycle;

@implementation TealiumPg

static NSString * const Tealium_Platform = @"ios_cordova";
static NSString * const Tealium_LibVersion = @"5.3.2";
static NSString * const Tealium_MobileBaseURL = @"https://tags.tiqcdn.com/utag/%@/%@/%@/mobile.html?%@=%@&%@=%@&%@=%@&%@=%@";
static NSString * const Tealium_PluginVersion = @"Tealium-Cordova-1.1.0";
- (void) init: (CDVInvokedUrlCommand*)command {
    // Check command.arguments here.
//[self.commandDelegate runInBackground:^{
    CDVPluginResult* pluginResult = nil;
    NSDictionary* arguments;
    NSString* accountName;
    NSString* profileName;
    NSString* environmentName;
    NSString* instanceName;
    NSString* collectDispatchURL;
    NSString* dataSourceId;
    NSString* collectDispatchProfile;
    // Below functions did not work as regular methods during Cordova build - added inline below
    NSTimeInterval ti = [[NSDate date] timeIntervalSince1970];
    long tiLong = (long)ti;
    NSString *timestamp = [NSString stringWithFormat:@"%li", tiLong];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString* isLifecycleEnabled = nil;

    @try {
        arguments = [command.arguments objectAtIndex:0];
        accountName = [arguments objectForKey:@"account"];
        profileName = [arguments objectForKey:@"profile"];
        environmentName = [arguments objectForKey:@"environment"];
        instanceName = [arguments objectForKey:@"instance"];
        dataSourceId = [arguments objectForKey:@"dataSourceId"];
        isLifecycleEnabled = [arguments objectForKey:@"isLifecycleEnabled"];
        collectDispatchProfile = [arguments objectForKey:@"collectDispatchProfile"];
        collectDispatchURL = [arguments objectForKey:@"collectDispatchURL"];
        if ([accountName length] == 0) {
            // account name not valid - set error response
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tealium: Account Name is null or empty. Please provide a valid account name."];
        } else if ([instanceName length] == 0) {
            // instance name not valid - set error response
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tealium: Instance Name is null or empty. Please provide a valid instance name."];
        } else if ([profileName length] == 0) {
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
            // override Collect service dispatch URL
            if (collectDispatchProfile != nil && collectDispatchURL == nil) {
                collectDispatchURL = @"https://collect.tealiumiq.com/vdata/i.gif?tealium_account=%@&tealium_profile=%@";
                collectDispatchURL = [NSString stringWithFormat: collectDispatchURL, accountName, collectDispatchProfile];
            }
            if (collectDispatchURL != nil) {
                // configuration.overrideCollectDispatchURL = collectDispatchURL;
                [configuration setOverrideCollectDispatchURL:collectDispatchURL];
            }
            // Enable or disable lifeycle autotracking based on option passed in at init time
            if ([isLifecycleEnabled isEqualToString:@"true"]){
                [configuration setAutotrackingLifecycleEnabled:YES];
            } else {
                [configuration setAutotrackingLifecycleEnabled:NO];
            }
            if (dataSourceId != nil){
                [configuration setDatasourceId:dataSourceId];
            }
            
            // create a new Tealium instance using the instance name passed in
            Tealium * instance = [Tealium newInstanceForKey:instanceName configuration:configuration];
            if (instance != nil) {
                [instance addPersistentDataSources:@{@"tealium_plugin_version":Tealium_PluginVersion}];
            }
            // set success response - we initialized successfully with no reported errors
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"Tealium: Tealium init successful!"];
        }
        // send the plugin response - success or failure
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
//}];
}

-  (void) track:(CDVInvokedUrlCommand*)command {
        // Check command.arguments here.
[self.commandDelegate runInBackground:^{
    CDVPluginResult* pluginResult = nil;
    NSDictionary* arguments;
    NSString* eventType;
    NSString* instanceName;
    NSString* screenTitle;
    NSString* eventId;
    NSDictionary* eventData;
    NSData *returnData;
    NSString *returnString;
    Tealium* teal;
    @try {
        arguments = [command.arguments objectAtIndex:0];
        eventType = [arguments objectForKey:@"eventType"];
        eventData = [arguments objectForKey:@"eventData"];
        instanceName = [arguments objectForKey:@"instance"];
        eventId = [eventData objectForKey:@"link_id"];
        screenTitle = [eventData objectForKey:@"screen_title"];
        returnData = [NSJSONSerialization dataWithJSONObject:eventData options:NSJSONWritingPrettyPrinted error:nil];
        returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        teal = [Tealium instanceForKey:instanceName];
        if (teal == nil) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tealium: Track was called, but Tealium instance was nil/not initialized yet."];
        } else {
            if ([eventType length] > 0) {
                if ([eventType isEqualToString:@"view"]) {
                    [[Tealium instanceForKey:instanceName] trackViewWithTitle:screenTitle dataSources:eventData];
                } else if ([eventType isEqualToString:@"link"]) {
                    [[Tealium instanceForKey:instanceName] trackEventWithTitle:eventId dataSources:eventData];
                }
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returnString];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
            }
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tealium: One of the arguments provdied to the track command is invalid."];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
}];
}

- (void) setPersistent: (CDVInvokedUrlCommand*)command {

[self.commandDelegate runInBackground:^{
    CDVPluginResult* pluginResult = nil;
    NSDictionary* arguments = nil;
    NSString* instanceName;
    NSString* keyName = nil;
    NSString* remove = nil;
    NSObject* receivedData = nil;
    NSMutableDictionary* data = [[NSMutableDictionary alloc]init];
    NSString* returnString = @"Persistent data source set successfully";
    Tealium* teal = nil;
    @try {
        arguments = [command.arguments objectAtIndex:0];
        instanceName = [arguments objectForKey:@"instance"];
        keyName = [arguments objectForKey:@"keyName"];
        receivedData = [arguments objectForKey:@"data"];
        remove = [arguments objectForKey:@"remove"];
        teal = [Tealium instanceForKey:instanceName];
        if (teal != nil) {
            if ([remove isEqualToString:@"true"]) {
                [teal removePersistentDataSourcesForKeys:@[keyName]];
            } else if (keyName != nil && receivedData != nil) {
                if ([receivedData isKindOfClass:[NSString class]] || [receivedData isKindOfClass:[NSArray class]]){
                    data[keyName] = receivedData;
                    [teal addPersistentDataSources:data];
                }
            }
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returnString];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tealium: Persistent data source could not be added, as Tealium is not yet initialized (Tealium instance was NIL)"];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
}];
}

- (void) setVolatile: (CDVInvokedUrlCommand*)command {
        // Check command.arguments here.
[self.commandDelegate runInBackground:^{
    CDVPluginResult* pluginResult = nil;
    NSDictionary* arguments = nil;
    NSString* instanceName;
    NSString* keyName = nil;
    NSString* remove = nil;
    NSObject* receivedData = nil;
    NSMutableDictionary* data = [[NSMutableDictionary alloc]init];
    NSString* returnString = @"Volatile data source set successfully";
    Tealium* teal = nil;
    @try {
        arguments = [command.arguments objectAtIndex:0];
        instanceName = [arguments objectForKey:@"instance"];
        keyName = [arguments objectForKey:@"keyName"];
        receivedData = [arguments objectForKey:@"data"];
        remove = [arguments objectForKey:@"remove"];
        teal = [Tealium instanceForKey:instanceName];
        if (teal != nil) {
            if ([remove isEqualToString:@"true"]) {
                [teal removeVolatileDataSourcesForKeys:@[keyName]];    
            } else if (keyName != nil && receivedData != nil) {
                if ([receivedData isKindOfClass:[NSString class]] || [receivedData isKindOfClass:[NSDictionary class]] || [receivedData isKindOfClass:[NSArray class]]){
                    data[keyName] = receivedData;
                    [teal addVolatileDataSources:data];    
                }
            }
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returnString];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tealium: Volatile data source could not be added, as Tealium is not yet initialized (Tealium instance was NIL)"];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
}];
}

- (void) getPersistent: (CDVInvokedUrlCommand*)command {
        // Check command.arguments here.
[self.commandDelegate runInBackground:^{
    // persistent data on ios technically can store NSDictionary objects, but Android cannot. 
    // To keep feature parity in the plugin, NSObjects cannot be returned or stored.
    CDVPluginResult * pluginResult = nil;
    NSDictionary * arguments = nil;
    NSString * instanceName;
    NSString * keyName = nil;
    Tealium * teal = nil;
    @try {
        arguments = [command.arguments objectAtIndex:0];
        instanceName = [arguments objectForKey:@"instance"];
        keyName = [arguments objectForKey:@"keyName"];
        teal = [Tealium instanceForKey:instanceName];
        // not sure what data type the return value is yet
        id returnValue = nil;
        if (teal != nil) {
           NSDictionary * persistentData = [teal persistentDataSourcesCopy];
           returnValue = persistentData[keyName];
           if (returnValue == nil) {
              pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:nil];
           } else if ([returnValue isKindOfClass:[NSString class]]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returnValue];
           } else if ([returnValue isKindOfClass:[NSArray class]]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:returnValue];
           } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:nil];
           }
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tealium: Persistent data source could not be found, as Tealium is not yet initialized (Tealium instance was NIL)"];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
}];
}

- (void) getVolatile: (CDVInvokedUrlCommand*)command {
        // Check command.arguments here.
[self.commandDelegate runInBackground:^{
    CDVPluginResult * pluginResult = nil;
    NSDictionary * arguments = nil;
    NSString * instanceName;
    NSString * keyName = nil;
    Tealium * teal = nil;
    @try {
        arguments = [command.arguments objectAtIndex:0];
        instanceName = [arguments objectForKey:@"instance"];
        keyName = [arguments objectForKey:@"keyName"];
        teal = [Tealium instanceForKey:instanceName];
        // not sure what data type the return value is yet
        id returnValue = nil;
        if (teal != nil) {
           NSDictionary * volatileData = [teal volatileDataSourcesCopy];
           returnValue = volatileData[keyName];
           if (returnValue == nil) {
                // can't return null literal, so return string value null to indicate value not found
                // pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:@"null"];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:nil];
           } else if ([returnValue isKindOfClass:[NSDictionary class]]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:returnValue];
           } else if ([returnValue isKindOfClass:[NSString class]]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returnValue];
           } else if ([returnValue isKindOfClass:[NSArray class]]) {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsArray:returnValue];
           } else {
            // data type not supported - only possible data types are Dictionary, String, Array
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:nil];
           }
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tealium: Volatile data source could not be found, as Tealium is not yet initialized (Tealium instance was NIL)"];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
}];
}

- (void) addRemoteCommand: (CDVInvokedUrlCommand*)command {
        // Check command.arguments here.
[self.commandDelegate runInBackground:^{
    __block CDVPluginResult * pluginResult = nil;
    NSDictionary * arguments = nil;
    NSString * instanceName;
    NSString * remoteCommandName = nil;
    Tealium * teal = nil;
    @try {
        arguments = [command.arguments objectAtIndex:0];
        instanceName = [arguments objectForKey:@"instance"];
        remoteCommandName = [arguments objectForKey:@"commandName"];
        teal = [Tealium instanceForKey:instanceName];
        if (_tagBridgeCallbackIds == nil) {
            _tagBridgeCallbackIds = [[NSMutableDictionary alloc] init];
        }
        _tagBridgeCallbackIds[remoteCommandName] = command.callbackId;
        if (teal != nil) {
            [teal addRemoteCommandID:remoteCommandName description:@"Auto generated Cordova remote command" targetQueue:dispatch_get_main_queue() responseBlock:^(TEALRemoteCommandResponse * _Nonnull response) {
               NSDictionary *tagBridgeResponse = [response requestPayload];
               pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsDictionary:tagBridgeResponse];
               [pluginResult setKeepCallbackAsBool:YES];
               NSString *commandCallbackId = _tagBridgeCallbackIds[tagBridgeResponse[@"command_id"]];
               [self.commandDelegate sendPluginResult:pluginResult callbackId:commandCallbackId];
            }];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_NO_RESULT];
            [pluginResult setKeepCallbackAsBool:YES];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tealium: Volatile data source could not be found, as Tealium is not yet initialized (Tealium instance was NIL)"];
        }
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
    @catch (NSException *exception) {
        pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR];
        [self.commandDelegate sendPluginResult:pluginResult callbackId:command.callbackId];
        return;
    }
}];
}

@end
