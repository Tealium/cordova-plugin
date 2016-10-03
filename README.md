Cordova Plugin 1.0.2
====================
## Brief

This plugin provides the means to tag Cordova built applications for the purposes of leveraging [Tealium's tag management platform (Tealium IQ)](http://tealium.com/products/enterprise-tag-management/), which permit [Tealium-enabled mobile apps](http://tealium.com/products/enterprise-tag-management/mobile/) to add, remove or edit analytic services remotely, in real-time, without requiring a code rebuild or new release to take effect.

### Table of Contents ###

- [Requirements](#requirements)
- [Embedded Tealium Libraries](#embedded-tealium-libraries)
- [Upgrade Notice](#upgrade-notice)
- [Add Plugin](#add-plugin)
- [Add Tracking](#add-tracking)
- [Lifecycle Tracking](#lifecycle-tracking)
- [Removing Tealium (optional)](#removing-tealium-optional)
- [Troubleshooting](#troubleshooting)
- [Known Issues](#known-issues)
- [Change Log](#change-log)

## Requirements

* Cordova 5.1.1+

## Embedded Tealium Libraries

* [Tealium iOS 5.0.4](https://www.github.com/Tealium/tealium-ios) including lifecycle module (TealiumIOSLifecycle.framework)
* [Tealium Android 5.0.4](https://www.github.com/Tealium/tealium-android) including lifecycle module (tealium.lifecycle-5.0.4.aar)

## Upgrade Notice

If upgrading from a Cordova Tealium plugin prior to 0.9.6, first issue the following commands:

```cordova plugin rm com.tealium.cordova.compact```

```cordova plugin add ../Tealium```

This assumes that you are in the root directory for your app, and the Tealium plugin is located 1 level up the directory tree in a directory called "Tealium". If this is not the case, modify the commands accordingly.

## Add Plugin
From the Command-Line Interface (CLI), first:

1. ```cordova create </PATH_TO_PROJECT>```
2. ```cd in to project```
3. ```cordova platform add <PLATFORM>```
4. ```cordova plugin add </LOCAL_PATH_TO_TEALIUM_PLUGIN/>```
5. ```cordova build <PLATFORM>```

Then init the library in your project:

```javascript
tealium.init({
account : "tealiummobile" 		// CHANGE REQUIRED: Your account.
, profile : "demo" 				// CHANGE REQUIRED: Profile you wish to use.
, environment : "dev" 			// CHANGE REQUIRED: Desired target environment - "dev", "qa", or "prod".
, instance : "tealium"          // CHANGE OPITONAL: This is the instance name you will use to refer to your tracker once created.
, isLifecycleEnabled : "true" // CHANGE OPTIONAL: If you wish to disable lifecycle tracking (launch, wake, sleep), set this value to STRING false (not boolean false)
});
```
Please note: Lifecycle tracking is enabled by default if you do not pass any value for isLifecycleEnabled. You must pass the string value "false" to disable lifecycle tracking.

#### Overriding the Tealium Collect Dispatch URL (AudienceStream)

By default, the core iOS and Android libraries send Tealium Collect data to the "main" profile in your Tealium account if you do not specify an alternative. The Cordova plugin now allows you to do this by passing one of two options at init time:

collectDispatchURL - This must be passed a full URL in the format:

```https://datacloud.tealiumiq.com/vdata/i.gif?tealium_account=<ACCOUNT>&tealium_profile=<PROFILE>```

Sample code (not production ready):

```javascript
function tealInit (accountName, profileName, environmentName, instanceName) {
tealium.init({account : accountName, 
				profile : profileName, 
				environment : environmentName, 
				instance : instanceName || window.tealium_instance 				, isLifecycleEnabled: "true"
             , collectDispatchURL:collectDispatchURL:"https://datacloud.tealiumiq.com/vdata/i.gif?tealium_account="+accountName+"&tealium_profile="+profileName
            });
}
```
collectDispatchProfile - This is only effective if no value has been passed for the collectDispatchURL parameter. Simply pass the profile name as a string to which you would like the data sent. The account name will be the same account you use to initialize Tealium.
Sample code (not production ready):

```javascript
function tealInit (accountName, profileName, environmentName, instanceName) {
tealium.init({account : accountName, 
                profile : profileName, 
                environment : environmentName, 
                instance : instanceName || window.tealium_instance              , isLifecycleEnabled: "true"
             , collectDispatchProfile:profileName
            });
}
```

### Add Tracking
The following is an example of how to track events or view changes:

```javascript
tealium.track("view", // "view" or "link"
{ "custom_key" : "custom_val" }, // Object containing key-value pairs.
"tealium" // Replace this with your instance ID
);
```

Note: As a rule of thumb, "view" should be used whenever a screen view takes place, while "link" is used to track user interaction events, such as button clicks. These methods correspond directly to "utag.view" and "utag.link" in Tealium IQ desktop implementations.

#### The "instance" Argument
In previous versions of the plugin (pre 0.9.6), only a single instance of Tealium was supported. In the new version, multiple instances of Tealium can be created. The new plugin therefore requires an instance ID to be passed at initialization time, and with each subsequent tracking request. If you are upgrading, you will therefore need to modify your code to specify a tracking instance. If you only require a single instance, it is recommended to create a global variable to store your instance ID, and pass this variable on each tracking call. An example of this is shown in the sample app.

### Sending data with every hit
Some data sources may be required on every hit generated by an app (e.g. user id). To save having to manually add this data to every hit, the Cordova plugin gives you the option to store the data as either "volatile" (deleted at app termination), or "persistent" (stored permanently until manually deleted). From the point the data is added, it will be appended to every hit, including lifecycle hits.

API usage:

- ```tealium.addPersistent("<keyname>", "<value>", window.tealium_instance);```
*Adds a persistent data source named <keyname> with value <value> to the persistent data store*
- ```tealium.removePersistent("<keyname>", window.tealium_instance);```
*Removes a persistent data source named <keyname> from the persistent data store*
- ```tealium.addVolatile("<keyname>", "<value>", window.tealium_instance);```
*Adds a volatile data source named <keyname> with value <value> to the persistent data store*
- ```tealium.removeVolatile("<keyname>", window.tealium_instance);```
*Removes a volatile data source named <keyname> from the volatile data store*

## Lifecycle tracking
This plugin includes automatic tracking for lifecycle events (launch, wake, sleep). Due to some peculiarities with the Cordova app lifecycle, this is accomplished by hooking into some helper methods that Cordova provides at the JavaScript level. In the interests of absolute clarity and transparency, here are the events we are using:

- "deviceready" - Tealium event "launch": Triggered when the app is launched from a "cold" launch, i.e. app not started from background. On Android, this event could also occur if the OS has destroyed the app's activity whilst in the background due to low memory on the device. This may result in the launch and wake events being fired in quick succession. Additionally, due to a race condition at launch, the launch event has an artificial 700ms timeout before it fires, to allow the Tealium SDK to fully initialize.

- "pause" - Tealium event "sleep": Triggered when the app is put into the background

- "resume" - Tealium event "wake": Triggered when the app is brought back into the foreground 

## Building The Sample App

- Navigate into the sample app root directory (should be "TealiumSample")
- Run command ```cordova platform add ios```
- Run command ```cordova platform add android```
- Run command ```cordova build ios```
- Run command ```cordova build android```
- The sample app will be built with the Tealium plugin included. Build outputs can be found in the TealiumSample/platforms/\<platform\>/build

## Removing Tealium (Optional)
In the CLI, in your Cordova project folder run:
```
cordova plugin rm com.tealium.cordova.v5
```

## Troubleshooting
Once the app is compiled, you can use the Safari Developer Tools for iOS and the Chrome Developer Tools for Android to remotely inspect the Tealium web view.

For Chrome/Android, go to "chrome://inspect" and look for "mobile.html".
For Safari/iOS, go to Develop \-\> \<Your Device Name\> \-\> "mobile.html".

All network requests generated by the Tealium plugin will appear in the "Network" tab of the developer tools for each browser.

Please note that you must connect your device with a USB cable to use this feature. 

Any errors logged during Tealium initialization will be stored on the global variable window.tealium\_cordova\_error. If Tealium init fails, check this variable in the JavaScript console (via Chrome or Safari) for error messages. Errors are stored here, because it is not always possible to inspect the app in time before the init occurs, so this method allows for later access to the error message.

### Gotchas
- iOS: After adding the plugin to your cordova project, you must load your app's ".xcodeproj" file in XCode and add "TealiumIOS.framework" and "TealiumIOSLifecycle.framework" in your project settings as an Embedded Binary. Unfortunately, Cordova does not provide a method to automate this via the plugin.xml file. You can find "Embedded Binaries" under Project settings > General > Targets (Your App Name) > Embedded Binaries. Simply click the "+" button and select TealiumIOS.framework and TealiumIOSLifecycle.framework from the list. Screenshot:

![Embedded Binaries](images/embedded_binaries.png)

- If you have any issues building your app, you may need to remove and re-add the platform using the following Cordova command:

```cordova platform rm <platform>```

```cordova platform add <platform>```

Substitute "platform" for either "android" or ios as appropriate.

This usually also resolves spurious XCode code signing errors when building for a physical device. 

- iOS: By default, Tealium includes simulator support for iOS (we provide a "fat" framework). This works fine for development builds, but will cause errors upon submission to the app store. For this reason, we provide a "Device Only" build without simulator support in the "DeviceOnly" directory of this repository. Please switch to the "DeviceOnly" build of the plugin prior to App Store submission. The only difference between the 2 plugins is that the ".framework" files for the core iOS SDK have had the simulator support removed. All other Cordova plugin files remain unchanged.

## Known Issues
- (Affects Tealium Collect ONLY - not IQ) Arrays are not processed correctly: Currently, the mechanism used to send data to AudienceStream (VDATA) does not process arrays correctly as a "Set of strings". Additionally, the core iOS and Android libraries do not currently send arrays in the correct format for the VDATA pixel. Both issues are currently being fixed, and should be ready in time for the next release of this plugin. Arrays ARE correctly passed to Tealium IQ for processing by JavaScript tags. If you need to pass arrays to AudienceStream, the suggested workaround is to disable Tealium Collect in the profile's publish settings, and add the Tealium Collect tag via Tealium IQ.

## Roadmap
- Improved support for the [Tealium AudienceStream](http://tealium.com/products/audiencestream/) Customer Data Platform to retrieve visitor profile data as well as collect data
- Windows Phone support to be investigated/added (no timeline as yet). Will include lib https://github.com/Tealium/win-library

## Change Log
- 1.0.2 Updated sample app to include examples for volatile and persistent data API calls
- 1.0.2 Updated README.md to detail new API calls
- 1.0.2 Added API calls to add/remove persistent data and volatile data
- 1.0.2 Android Only - In previous versions of the plugin, the only valid data type was a string. This was not intended behavior. This has been corrected to now accept the data type passed in (String, JSON Object or Array)
- 1.0.2 Added option to override the URL for the Tealium Collect dispatch service (AudienceStream). Previously all calls went to the "main" profile and there was no possibility to override this. This is passed as one of two arguments at compile time (see above notes)
- 1.0.2 Upgraded iOS core library to 5.0.4
- 1.0.2 Upgraded Android core library to 5.0.4
- - 1.0.2 Fixed lifecycle tracking on iOS by switching to using Cordova lifecycle events instead of native Android events
- 1.0.2 Fixed lifecycle tracking on Android by switching to using Cordova lifecycle events instead of native Android events
- 1.0.2 Minor optimizations/refactoring in the Java/Objective-C plugin code
- 1.0.1 Upgraded core libraries to Android 5.0.2 and iOS 5.0.3 respectively
- 1.0.1 Added lifecycle tracking by default to Android and iOS & additional config option to disable lifecycle tracking
- 1.0.1 Added option to override the init successCallback function (see pull request https://github.com/Tealium/cordova-plugin/pull/8/commits/70ca605393119bac36a7ba66f2ec205a52edf324)
- 0.9.6 Multiton pattern now fully supported (allows multiple instances of IQ to run in the same app)
- 0.9.6 Upgraded to use new Tealium core libraries for Android and iOS (v5.0.0 and 5.0.1 respectively)
- 0.9.4 Fixed Typo in config.xml
- 0.9.2 Update to Plugin.xml
- 0.9.0 Update of older phonegap-plugin to Cordova 5.1.1


------------------------------------------------------

Copyright (C) 2012-2016, Tealium Inc.
