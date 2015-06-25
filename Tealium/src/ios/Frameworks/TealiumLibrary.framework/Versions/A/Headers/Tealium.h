//
//  Tealium.h
//
//  ------------
//  *** INFO ***
//  ------------
//
//  Library Type: COMPACT
//
//  Minimum OS Version supported: iOS 5.1.1+
//
//  Brief: The is the primary TealiumiOS library class object for tracking analytics data on iOS devices.  It includes both the UI Autotracking and Mobile Companion features. The below methods in this header file are the only public methods needed to initialize and run the library. Configuration should be done from Tealium's IQ dashboard at https://www.tealium.com
//
//  Authors: Originally Created by Charles Glommen and Gautam Dey, rewritten, extended and maintained by Jason Koo and George Webster
//
//  Copyright: (c) 2014 Tealium, Inc. All rights reserved.
//
// ----------------------------------
// *** QUICK INSTALL INSTRUCTIONS ***
// ----------------------------------
//
// 1. Copy/link the TealiumiOSLibrary.framework into your XCode project
// 
// 2. Link the following framework to your project:
//
//      * SystemConfiguration.framework
//      * UIKit.framework
// 
// 2a. Optionally link the following framework:
// 
//      * CoreTelephony.framework (for carrier data tracking)
// 
// 3. Add the class level init method (initSharedInstance:profile:target:options:globalCustomData:) to your app delegate or wherever your primary root controller is initialized
// 
// 4. Add "#import <TealiumLibrary/Tealium.h>" to your -Prefix.pch file, within the #ifdef __OBJC__ block statement for app wide access. Otherwise, add this import statment to the header file of every class that will use the library.
//
//  -----------------------
//  *** ADDITIONAL INFO ***
//  -----------------------
//  This library runs the majority of it's operations on a background thread, so there is no need to wrap it, although doing so will not adversly affect it.
// 
//  See the github Readme.md file and wiki at: https://github.com/Tealium/ios-library for full developer instructions. You will require a Github account and permissions approval by your Tealium Account Manager to access.
//
//  Checkout our mobile related articles at http://community.tealiumiq.com for supplemental information. See your Tealium Account Manager for access.

#import <UIKit/UIKit.h>
#import "TealiumConstants.h"
#import "TealiumRemoteCommandResponse.h"

@interface Tealium : NSObject

#pragma mark - INITIALIZATION

/**
 Library status indicator.
 
 @return Boolean whether the Tealium library is currently active.
 */
+ (BOOL) isActive;

/**
 The Class-level init method. Available version 3.2+.
 
 @param accountName NSString of your Tealium account name
 @param profileName NSString of your account-profile name
 @param environmentName NSString Target environment (dev/qa/prod)
 @param options Tealium Options to configure the library. Multiple options may be used using a pipe (|) operator between options. Enter "0" or TLNone for no options.
 @param customData NSDictionary of additional global custom data added to every dispatch
 */
+ (void) initSharedInstance:(NSString *)accountName
                    profile:(NSString *)profileName
                     target:(NSString *)environmentName
                    options:(TealiumOptions)options
           globalCustomData:(NSDictionary *)customData;

/**
 Legacy version 3.0 Class-level init method. This method now calls the new recommended Class-level init method above, with no globalCustomData.
 
 @param accountName Name of Tealium account
 @param profileName Target Account profile
 @param environmentName Target profile environment (dev, qa, etc.)
 @param options USe Tealium Options constants to configure the library.
 */
+ (void) initSharedInstance:(NSString *)accountName
                    profile:(NSString *)profileName
                     target:(NSString *)environmentName
                    options:(TealiumOptions)options;

/**
 Legacy version 1.0 Class-level init method. This method now calls the new recommended Class-level init method above, with no options or globalCustomData.
 
 @param accountName Name of Tealium account
 @param profileName Target Account profile
 @param environmentName Target profile environment (dev, qa, etc.)
 */
+ (void) initSharedInstance:(NSString *)accountName
                    profile:(NSString *)profileName
                     target:(NSString *)environmentName;

/**
 New universal method for firing all manual tracking calls. Takes advantage of the auto-detected default data sources and additional Custom Data methods below (ie addCustomData:to: and addGlobalCustomData:).
 
 @param callType Enter either TealiumEventCall or TealiumViewCall for the appropriate track type
 @param eventData NSDictionary with custom data. Keys become Tealium IQ Data Sources. Values will be the value passed into the analytic variable mapped to the Data Source.
 @param object NSObject source of the call if you want auto property detection added to the tracking call for a particular object 
 */
+ (void) trackCallType:(NSString *)callType
            customData:(NSDictionary *)data
                object:(NSObject *)object;

/**
 Puts Tealium tagger to permenant sleep. This is an optional method if your app has a manual option for users to disable analytic tracking. Enable must be called to reactivate. Supercedes any remote configuration settings.
 */
+ (void) disable;

/**
 To re-enable the library from a disable call.
 */
+ (void) enable;

/**
 Use this method to access a copy of the library's global custom data dictionary.
 
 */
+ (NSMutableDictionary *) globalCustomData;

/**
 Use this method to add or edit additional data points to the global custom data that is availabe to all dispatches.
 
 @param additionalCustomData NSDictionary collection of any additional key-value data points to add or replace key-value pairs in the global custom data.
 */
+ (void) addGlobalCustomData:(NSDictionary *)additionalCustomData;

/**
 Use this method to remove data points from the global custom data that is availabe to all dispatches.
 
 @param keys NSArray collection of keys whose key-value pairs you wish to remove from the global custom data.
 */
+ (void) removeGlobalCustomDataForKeys:(NSArray *)keys;

/**
 Use this method to access a copy of any custom data dictionary associated with a given object.
 
 @param object is the target object to associate the custom data with. Required.
 */
+ (NSMutableDictionary *) customDataForObject:(NSObject *)object;

/**
 Use this method to add or edit custom data with a dispatch from a target object.
 
 @param customData NSDictionary collection of any additional key-value data points to associate with the target object. Required.
 @param object Any NSObject subclass that is the source trigger for the custom data. Required.
 */
+ (void) addCustomData:(NSDictionary *)customData toObject:(NSObject *)object;

/**
 Use this method to remove custom data associated with the target object.
 
 @param keys NSArray collection of keys whose key-value pairs you wish to remove from the target object's custom data.
 */
+ (void) removeCustomDataForKeys:(NSArray *)keys forObject:(NSObject *)object;

/**
 Add this method to your app delegate's application:didRegisterForRemoteNotificationsWithDeviceToken:  Required if wanting to make use of dynamic Push services via TIQ.
 */
+ (void) application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken;

/**
 Add this method to your app delegate's application:didFailToRegisterForRemoteNotificationsWithError:  Required if wanting to make use of dynamic Push services via TIQ.
 */
+ (void) application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error;

/**
 Add this method to your app delegate's application:didReceiveRemoteNotification:  Optional if you want to auto-track push notification dispatches.
 */
+ (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

/**
 Add this method to your app delegate's application:didReceiveRemoteNotification:fetchCompletionHandler:  Optional if you want to auto-track push notification dispatches.
 */
+ (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler;

/**
 Use this method to add remote commands that can be triggered via tag triggers enabled in your TIQ dashboard.
 
 @param name NSString identifier for the command.  Do not use an underscore (_) at the start of your name, as these are reserved.
 @param description Optional NSString description of what the command is expected to do.
 @param queue The target thread that should process the command block.
 @param command A block of code to be executed in the event this remote command id is triggered.
 */
+ (void) addRemoteCommandId:(NSString *)name
                description:(NSString *)description
                targetQueue:(dispatch_queue_t)queue
                      block:(void(^)(TealiumRemoteCommandResponse*response))command;

@end
