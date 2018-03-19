#import "tealium_adidentifier.h"
#import <Cordova/CDV.h>
@import TealiumIOSLifecycle;

@implementation TealiumPgAdIdentifier

- (void) setPersistent: (CDVInvokedUrlCommand*)command {

[self.commandDelegate runInBackground:^{
    CDVPluginResult* pluginResult = nil;
    NSDictionary* arguments = nil;
    NSString* instanceName;
    NSString* returnString = @"Advertising Identifiers set successfully";
    Tealium* teal = nil;
    @try {
        arguments = [command.arguments objectAtIndex:0];
        instanceName = [arguments objectForKey:@"instance"];
        teal = [Tealium instanceForKey:instanceName];
        if (teal != nil) {
            [teal addPersistentDataSources: [self getIdentifiers]];
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returnString];
        } else {
            pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tealium: Persistent Ad Identifiers could not be added, as Tealium is not yet initialized (Tealium instance was NIL)"];
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
    
    [self.commandDelegate runInBackground:^{
        CDVPluginResult* pluginResult = nil;
        NSDictionary* arguments = nil;
        NSString* instanceName;
        NSString* returnString = @"Advertising Identifiers set successfully";
        Tealium* teal = nil;
        @try {
            arguments = [command.arguments objectAtIndex:0];
            instanceName = [arguments objectForKey:@"instance"];
            teal = [Tealium instanceForKey:instanceName];
            if (teal != nil) {
                [teal addVolatileDataSources: [self getIdentifiers]];
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_OK messageAsString:returnString];
            } else {
                pluginResult = [CDVPluginResult resultWithStatus:CDVCommandStatus_ERROR messageAsString:@"Tealium: Volatile Ad Identifiers could not be added, as Tealium is not yet initialized (Tealium instance was NIL)"];
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

- (NSDictionary *) getIdentifiers {
    
    NSString* idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    NSString* idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    BOOL adTrackingEnabled = [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled];
    NSString* adTracking = adTrackingEnabled == YES ? @"true" : @"false";
    
    NSDictionary* dict = @{
                           @"device_advertising_id": idfa,
                           @"device_advertising_vendor_id": idfv,
                           @"device_advertising_enabled": adTracking
                           };

    return dict;
}

@end
