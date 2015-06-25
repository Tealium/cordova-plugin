//
//  Tealium.h
//
//  ------------
//  *** INFO ***
//  ------------
//  Version: 3.1c
//  Minimum OS Version supported: iOS 5.0+
//  Brief: The is the Compact TealiumiOS library for tracking analytics data on iOS devices ONLY (will not run simulator).  It DOES NOT include either the autotracking or Mobile Companion features. The below methods in this header file are the only public methods needed to initialize and run this library. Configuration should be done from Tealium's IQ dashboard at https://www.tealium.com
//  Authors: Originally Created by Charles Glommen and Gautam Day, rewritten and maintained by Jason Koo
//  Copyright: (c) 2014 Tealium, Inc. All rights reserved.
//
//  ----------------------------------
//  *** QUICK INSTALL INSTRUCTIONS ***
//  ----------------------------------
//  1. Copy the entire TealiumiOSLibrary.framework folder (including this header file) into your XCode project
//
//  2. Link the following 6 frameworks to your project:
//
//    * CoreTelephony.framework
//    * SystemConfiguration.framework
//
//  3. Add the class level init method (initSharedInstance:profile:target:options:) to your app delegate or wherever your primary root controller is initialized
//
//  4. Make certain in your Build Settings: Apple LLVM 5.0 - Code Generation: Instrument Program Flow is YES
// 
//  5. Add "#import <TealiumTealiumiOSLibrary/TealiumiOSTagger.h>" to your -Prefix.pch file, within the #ifdef __OBJC__ statement for app wide access. Otherwise, add this import statment in the header file of every object that will make use of the library.
//
//  !!! NOTE !!! The compact library will only run on a device/release target, and will not compile for the simulator
//
//  -----------------------
//  *** ADDITIONAL INFO ***
//  -----------------------
//  See the github Readme.md file at: https://github.com/Tealium/ios-library for the full developer instruction set and for a partical list of automatically tracked default data source keys and expected values. You will require a Github account and permissions approval by your Tealium Account Manager to access.
// 
//  Checkout our mobile related articles at http://community.tealiumiq.com for the most recent information, including an up-to-date list of all automatically tracked default data source keys and expected values. See your Tealium Account Manager for access.

#import <CoreFoundation/CoreFoundation.h>
#import <UIKit/UIKit.h>

@interface Tealium : NSObject

#pragma mark - INITIALIZATION
/*
 Available init option values - these must be set at init time and can not be changed remotely. NOTE: Setting your target environment to "prod" will force enable TLSuppressLogs option and ignore the TLDisableHTTPS option */
enum {
    TLNone                      = 0,
    TLSuppressLogs              = 1 << 0, /** Suppresses all non-error logs*/
    TLDisableExceptionHandling  = 1 << 1, /** Turns off crash tracking*/
    TLDisableLifecycleTracking  = 1 << 2, /** Turns off launch, wake, sleep & terminate reporting */
    TLDisableHTTPS              = 1 << 3, /** Switches from HTTPS to HTTP - NOT recommended for production release*/
    TLDisplayVerboseLogs        = 1 << 4, /** Print verbose logs to the console*/
    TLPauseInit                 = 1 << 5  /** Delays startup until resumeInit method called*/
};
typedef NSUInteger TealiumOptions;

// Support for pre 3.1 release namespace - Will be deprecated in next version
typedef Tealium TealiumiOSTagger;

/**
 Recommended Class-level init method. Available version 3.0+
 
 @warning Class-level messages are convenience messages for when a single account/profile/environment context exists. However, if more than one tealium context is needed (unlikely), or a dependency injection framework is already employed, it is recommended to directly utilize the instance init message init:profile:target:rootController:.
 @param accountName NSString of your Tealium account name
 @param profileName NSString of your account-profile name
 @param environmentName NSString Target environment (dev/qa/prod)
 @param options Tealium Options to configure the library. Multiple options may be used using a pipe (|) operator between options. Enter "0" or TLNone for no options.
 */
+ (Tealium*) initSharedInstance: (NSString*) accountName
                                 profile: (NSString*) profileName
                                  target: (NSString*) environmentName
                                 options: (TealiumOptions) options ;

/**
 Legacy version 1.0 Class-level init method.
 
 This method now calls the new recommended Class-level init method above, with no options.
 @param accountName Name of Tealium account
 @param profileName Target Account profile
 @param environmentName Target profile environment (dev, qa, etc.)
 */
+ (Tealium*) initSharedInstance: (NSString*) accountName
                                 profile: (NSString*) profileName
                                  target: (NSString*) environmentName;

/**
 Legacy version 2.0 Class-level init method. Use initSharedInstance:profile:target:options: instead. The root controller argument is now ignored and will be determined by the library - Will be deprecated next update.
 
 @param accountName NSString of your Tealium account name
 @param profileName NSString of your Tealium account-profile
 @param enviornmentName NSString of the target environment (dev/qa/prod)
 @param rootController UIViewController object that is root controlling object - library now auto finds this
 */
+ (Tealium*) initSharedInstance: (NSString*) accountName
                                 profile: (NSString*) profileName
                                  target: (NSString*) environmentName
                          rootController: (id) rootController;

/**
 For accessing the Tealium Library Singleton
 */
+ (Tealium*) sharedInstance;

/**
 Optional initialization method for creating multiple instances of the Tealium Tagger. This is NOT a recommended best practice, as additional mapping and tag configuration should occur within Tealium IQ.  This method is provided in the event you need to map data to 2 or more Tealium accounts.  Note, if autotracking is enabled (on by default), duplicate calls will result.
 
 @warning Class-level messages are convenience messages for when a single account/profile/environment context exists. However, if more than one tealium context is needed (unlikely), or a dependency injection framework is already employed, it is recommended to directly utilize the instance init message init:profile:target:navigationController:
 @param accountName Name of Tealium account
 @param profileName Target Account profile
 @param environmentName Target profile environment (dev, qa, etc.)
 @param rootController Root view controller. May be a UINavigationController, UITabeBarController or UISplitViewController. If parameter passed is nil then autoTracking will be disabled.
 */
- (Tealium*) init: (NSString*) accountName
                   profile: (NSString*) profileName
                    target: (NSString*) environmentName
                   options: (TealiumOptions) options;

/**
 Call this method if the TLPauseInit option was used in the library's init method to finalize the startup sequence. This option is required if you wish to add global custom data BEFORE the initial wake calls.
 */
- (void) resumeInit;

#pragma mark - MANUAL TRACKING METHODS
/*
 *  --------------------------------------------------------------------------
 *  !!! WARNING !!! Use these methods directly only if the autotracking feature is DISABLED or unable to track the target object. Double call dispatches may result otherwise.
 *  --------------------------------------------------------------------------
 */

// Call type options for manual track methods
extern NSString * const TealiumEventCall;
extern NSString * const TealiumViewCall;

/**
 New universal method for firing all manual tracking calls. Takes advantage of the auto-detected default data sources and additional Custom Data methods below (ie addCustomData:to: and addGlobalCustomData:).
 @param object The NSObject associated with the call.  Use UIViewControllers instead of UIView's for view tracking
 @param eventData NSDictionary with custom data. Keys become Tealium IQ Data Sources. Values will be the value passed into the analytic variable mapped to the Data Source.
 @param callType NSString of call type - use either provided constants "TealiumViewCall" for views or "TealiumEventCall" for events - other string values reserved for future use.
 */
- (void) track:(id) object
    customData:(NSDictionary*) customData
            as:(NSString*)callType;

#pragma mark - ADDITIONAL CUSTOM DATA
/*
 *  --------------------------------------------------------------------------
 *  *** NOTE *** The library's initial wake and view calls may occur before the below methods have had a chance to complete.  To ensure any custom global data is added to the library before these first calls, be sure to use the TLPauseInit option in the init method.  After all your custom data has been added, use the resumeInit call to complete the init process.
 *  --------------------------------------------------------------------------
 */

/**
 Add data source-value pairs to future calls related to the target object.
 
 @param dict NSDictionary of any additional data to pass to Tealium. Can not be nil
 @param object The object to attach the dict data to. Can not be nil
 */
- (void) addCustomData:(NSDictionary*)customData to:(NSObject*)object;

/**
 Adds multiple data source-value pairs to ALL objects for all future tracking calls
 
 @param customData NSDictionary of key-value pairs to become data source-value pairs in Tealium IQ. Nil will result in a NO return
 */
- (void) addGlobalCustomData:(NSDictionary*)customData;


#pragma mark - INFORMATION
/*
 *  --------------------------------------------------------------------------
 *  *** NOTE *** Mobile Companion is the recommended means of reading and confirming
 *  data tracked by the library outside of the dev console logs
 *  --------------------------------------------------------------------------
 */

/**
 Retrieves a Tealium generated Universally Unique Identifier that distinguishes the current device and app from other devices with your application.  If this UUID is not already available, it will generate a new UUID before returning. Use this method if you want to make use of the same id. NOTE: Do not confuse this with the deprecated UDID, which is no longer permitted by Apple
 
 @return An NSString object
 */
- (NSString*) retrieveUUID;

#pragma mark - OVERRIDE COMMANDS

/**
 Puts Tealium tagger to permenant sleep. This is an optional method if your app has a manual option for users to disable analytic tracking. Enable must be called to reactivate. Supercedes any remote configuration settings.
 */
- (void) disable;

/**
 To re-enable the library from a disable call.
 */
- (void) enable;

/**
 Method for overriding the default Tealium mobile html url destination for retrieving configuration and mapping data. Use a FULL url address (ie: HTTPS://www.mywebsite.com) NOTE: It is recommended you use the TLPauseInit option when using this method. Also note this method overrides the TLDisableHTTPS init option.
 @param override NSString of the full URL to override default with
 */
- (void) setMobileHtmlUrlOverride:(NSString*)override;

/**
 Overwrites Tealium's UUID created string. NOTE: Do not confuse UUID with the deprecated UDID, the identifier no longer supported by Apple
 
 @param uuid NSString to set Tealium UUID with
 @return BOOL answer if new UUID successfully overwrote Tealium's default
 */
- (BOOL) setUUID:(NSString*)uuid;

@end
