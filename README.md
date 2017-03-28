Tealium Cordova Plugin 1.1.0
============================
## Brief

This plugin provides the means to tag Cordova built applications for the purposes of leveraging [Tealium's tag management platform (Tealium IQ)](http://tealium.com/products/enterprise-tag-management/), which permit [Tealium-enabled mobile apps](http://tealium.com/products/enterprise-tag-management/mobile/) to add, remove or edit analytics services remotely, in real-time, without requiring a code rebuild or new release to take effect.

### Table of Contents ###

- [Requirements](#requirements)
- [Embedded Tealium Libraries](#embedded-tealium-libraries)
- [Upgrade Notice](#upgrade-notice)
- [Add Plugin](#add-plugin)
- [Add Tracking](#add-tracking)
- [Lifecycle Tracking](#lifecycle-tracking)
- [Building The Sample App](#building-the-sample-app)
- [Removing Tealium (optional)](#removing-tealium-optional)
- [TagBridge Remote Commands](#tagbridge-remote-commands)
- [Troubleshooting](#troubleshooting)
- [Known Issues](#known-issues)
- [Backwards Compatibility](#backwards-compatibility)
- [Roadmap](#roadmap)
- [Change Log](#change-log)

## Requirements

* Cordova 5.1.1+
* Node package ```node-xcode``` (install with ```npm i xcode```)
  * This is required to automatically add the Tealium libraries to the "embedded binaries" section of the Xcode project file. If you do not wish to use this feature, please go into the plugin directory (https://github.com/Tealium/cordova-plugin/tree/master/Tealium), delete or rename the ```plugin.xml``` file, and rename the ```plugin-noxcode.xml``` to ```plugin.xml```. This will remove the dependency on ```node-xcode```, but you will need to manually add the Tealium libraries to the embedded binaries section in the xcode project.

## Embedded Tealium Libraries

* [Tealium iOS 5.2.1](https://www.github.com/Tealium/tealium-ios) including lifecycle module (TealiumIOSLifecycle.framework)
* [Tealium Android 5.2.0](https://www.github.com/Tealium/tealium-android) including lifecycle module (tealium.lifecycle-5.0.4.aar)

## Upgrade Notice

If upgrading from a Cordova Tealium plugin prior to 0.9.6, first issue the following commands:

```cordova plugin rm com.tealium.cordova.compact```

```cordova plugin add ../Tealium```

This assumes that you are in the root directory for your app, and the Tealium plugin is located 1 level up the directory tree in a directory called "Tealium". If this is not the case, modify the commands accordingly.

## Add Plugin
### Using NPM
It is recommended to install the plugin via NPM. There are 2 packages available on npm:

1. tealium-cordova-plugin
2. tealium-cordova-deviceonly

The 2 plugins are identical, except that the "deviceonly" version has simulator support removed for iOS. You will need to switch to the deviceonly plugin before submitting to the Apple App Store to avoid getting error messages about invalid architectures. The Android builds in both packages are identical.

To add either plugin, ```cd``` into the directory in which your Cordova project resides, then run either:
```cordova plugin add tealium-cordova-plugin``` or ```cordova plugin add tealium-cordova-deviceonly```


### Manual Install
From the Command-Line Interface (CLI), first:

1. ```cordova create </PATH_TO_PROJECT>```
2. ```cd in to project```
3. ```cordova platform add <PLATFORM>```
4. ```cordova plugin add </LOCAL_PATH_TO_TEALIUM_PLUGIN/>```
5. ```cordova build <PLATFORM>```

See the example script included in the [Building the sample app](#building-the-sample-app) section for an automated approach

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

Sample code:

```javascript
function tealInit (accountName, profileName, environmentName, instanceName) {
tealium.init({account : accountName, 
				profile : profileName, 
				environment : environmentName, 
				instance : instanceName || window.tealium_instance 				, isLifecycleEnabled: "true"
             , collectDispatchURL:collectDispatchURL:"https://collect.tealiumiq.com/vdata/i.gif?tealium_account="+accountName+"&tealium_profile="+profileName
            });
}
```
collectDispatchProfile - This is only effective if no value has been passed for the collectDispatchURL parameter. Simply pass the profile name as a string to which you would like the data sent. The account name will be the same account you use to initialize Tealium.
Sample code:

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

## Add Tracking
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

Note: Only the following data types are supported

| Storage | Data Types Supported                                 | Examples                            |
|--------------|------------------------------------------------------|-------------------------------------|
| volatile     | ```String```, ```Array``` (of strings), ```Object``` | "abc", ["abc","bcd"], {"abc":"bcd"} |
| persistent   | ```String```, ```Array```(of strings)                | "abc", ["abc","bcd"]                |

API usage:

- ```tealium.addPersistent("<keyname>", "<value>", window.tealium_instance);```
*Adds a persistent data source named <keyname> with value <value> to the persistent data store*
- ```tealium.removePersistent("<keyname>", window.tealium_instance);```
*Removes a persistent data source named <keyname> from the persistent data store*
- ```tealium.addVolatile("<keyname>", "<value>", window.tealium_instance);```
*Adds a volatile data source named <keyname> with value <value> to the persistent data store*
- ```tealium.removeVolatile("<keyname>", window.tealium_instance);```
*Removes a volatile data source named <keyname> from the volatile data store*

### Retrieving values from persistent/volatile storage
If you wish to check the contents of an existing volatile/persistent data variable previously stored via the ```addPersistent``` or ```addVolatile``` API methods, you can do so using the following methods:

- ```tealium.getPersistent("<keyname>", window.tealium_instance, callback);```
*Retrieves a persistent data source named <keyname> from the persistent data store, and then passes the value into the callback function passed in the 3rd parameter*
- ```tealium.getVolatile("<keyname>", window.tealium_instance, callback);```
*Retrieves a persistent data source named <keyname> from the persistent data store, and then passes the value into the callback function passed in the 3rd parameter*

Please note: 

* These methods will return ```null``` on the JavaScript side if the requested data could not be found
* The returned value could be any of the supported data types listed above. You should therefore add a safety check to ensure that the returned data is of the expected datatype before performing any operations on it (e.g. check that a value expected as an array is really an array before trying to use the Array.push prototype method)

Example:

```
// retrieves a volatile variable called "myvolatilevariable"
tealium.getVolatile("myvolatilevariable", window.tealium_instance, function (val) {
        // this callback will be called when the volatile data source has been found
        if (val === null) {
        // returns null if data was not found
            alert("Requested volatile data could not be found");        
        } else {
            alert("Volatile object data returned: " + "myvolatilevariable = " + val.toString());        
        }   
    });
```

## Lifecycle tracking
This plugin includes automatic tracking for lifecycle events (launch, wake, sleep). On iOS, we are using the Tealium library's built-in automatic lifecycle tracking. However, due to some peculiarities with the Cordova app lifecycle on Android, this is accomplished by hooking into some helper methods that Cordova provides at the JavaScript level. In the interests of absolute clarity and transparency, here are the events we are using:

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
- An optional bash script is included which will first remove old plugins and then install the new version. Feel free to use this script or modify for your needs. Currently, the script does a ```cordova platform rm <PLATFORM>``` for both Android and iOS, as on several occasions, we have found that not performing this step will leave behind cached remnants of old plugin versions. The bash script is located at ```TealiumSample/autobuild.sh```

## Removing Tealium (Optional)
In the CLI, in your Cordova project folder run:
```
cordova plugin rm com.tealium.cordova.v5
```

## TagBridge Remote Commands
The Remote Command system allows you to control certain aspects of your app remotely using Tealium IQ. Starting in version 1.1.0 of the Cordova plugin, it's possible to register a JavaScript callback function with the Tealium plugin, which can then be called remotely from Tealium iQ whenever a specific set of load rules is satisfied.

For example, you might wish to trigger a modal overlay in your Cordova app, which invites the user to participate in a survey when the user performs a specific function (completes a purchase, subscribes to emails etc.). The advantage of controlling this in Tealium iQ is that the text displayed in the modal overlay can be configured remotely, and additionally the overlay can be completely enabled/disabled via Tealium iQ without the need for an app release. You could also use Tealium iQ to hold config information for other 3rd party SDKs/plugins (e.g. API keys), which would give you the ability to quickly and dynamically change this information based on some information passed into Tealium iQ by a trackEvent or trackView call. For example, you could dynamically change API keys based on the Tealium environment currently loaded in the app (dev = XXXXXX, prod = YYYYYY).

### RemoteCommand Code Example

```
// this code would normally be implemented in the main .js file for your app
function tealiumInit(accountName, profileName, environmentName, instanceName){
        tealium.init({
                 account : accountName       // REQUIRED: Your account.
                 , profile : profileName              // REQUIRED: Profile you wish to use.
                 , environment : environmentName         // REQUIRED: "dev", "qa", or "prod".
                 , instance : instanceName || window.tealium_instance // instance name used to refer to the current tealium instance
                 , isLifecycleEnabled: "true" // explicitly enabling lifecycle tracking. Note string value required, not boolean
                 // , collectDispatchURL:"https://collect.tealiumiq.com/vdata/i.gif?tealium_account=services-crouse&tealium_profile=mobile"
                 , collectDispatchProfile:"demo"
                 });
}

function onDeviceReady() {
    // call our custom tealiumInit function
    tealiumInit("tealiummobile", "demo", "dev", "tealium_main");
    console.log("onDeviceReady");
    tealium.addRemoteCommand("getTIQMessage", window.tealium_instance, function (message){
		 // message is a JSON object containing mapped key-value pairs from TiQ
        if (message && message.message_text) {
            alert(message.message_text);
        }
    });
    tealium.addRemoteCommand("getAnotherMessage", window.tealium_instance, function (message){
        // message is a JSON object containing mapped key-value pairs from TiQ
        if (message && message.message_text) {
            alert(message.message_text);
        }    
     });
    // simple example to change the background color of the view to a color code returned from TiQ
    tealium.addRemoteCommand("changeBackgroundColor", window.tealium_instance, function (message){
        // message is a JSON object containing mapped key-value pairs from TiQ
        if (message && message.bg_colorcode) {
            document.body.style.background = message.bg_colorcode;
        }    
     });     
}
```
This example is also demonstrated in the TealiumSample app included on GitHub. 

### Tealium iQ Config
*Prerequisite:* Ensure you are using utag.js loader version 4.40 or above, or you may encounter issues with commands double-firing.

1. Add the "TagBridge Custom Command" tag in Tealium iQ, and in the "Command ID" box on the tag config screen, enter the name of the command you wish to call, e.g. changeBackgroundColor
2. Add any load rules you wish to associate with this command, e.g. "screen_title contains confirmation screen"
3. Create a new variable in Tealium iQ called "app_background_color" or similar
4. Add a new mapping from "app_background_color" to a destination of "bg_colorcode" in the "TagBridge Custom Command" tag
5. In an extension, set the value of "app_background_color" to the desired Hex color code (e.g. #FFFF00 for yellow, hash/pound sign included).
6. Once you have published your profile, and when your load rules are satisfied, the app background color will change to yellow.

Idea: you could use a combination of setTimeout and cookies in a Tealium iQ JavaScript extension to fire your Remote Command after a delay, or only once within a given time period (e.g. 30 days).

## Troubleshooting
Once the app is compiled, you can use the Safari Developer Tools for iOS and the Chrome Developer Tools for Android to remotely inspect the Tealium web view.

For Chrome/Android, go to "chrome://inspect" and look for "mobile.html".
For Safari/iOS, go to Develop \-\> \<Your Device Name\> \-\> "mobile.html".

All network requests generated by the Tealium plugin will appear in the "Network" tab of the developer tools for each browser.

Please note that you must connect your device with a USB cable to use this feature. 

Any errors logged during Tealium initialization will be stored on the global variable window.tealium\_cordova\_error. If Tealium init fails, check this variable in the JavaScript console (via Chrome or Safari) for error messages. Errors are stored here, because it is not always possible to inspect the app in time before the init occurs, so this method allows for later access to the error message.

### Gotchas
- iOS: If for some reason you cannot use the automatic hook included in the plugin, which adds the Tealium ```.framework``` files to the Embedded Binaries section in your project, you will need to perform this step manually. After adding the plugin to your cordova project, you must load your app's ".xcodeproj" file in XCode and add "TealiumIOS.framework" and "TealiumIOSLifecycle.framework" in your project settings as an Embedded Binary. You can find "Embedded Binaries" under Project settings > General > Targets (Your App Name) > Embedded Binaries. Simply click the "+" button and select TealiumIOS.framework and TealiumIOSLifecycle.framework from the list.

- If you have any issues building your app, you may need to remove and re-add the platform using the following Cordova command:

```cordova platform rm <platform>```

```cordova platform add <platform>```

Substitute "\<platform\>" for either "android" or "ios" as appropriate.

This usually also resolves spurious XCode code signing errors when building for a physical device. The ```autobuild.sh``` bash script included in the TealiumSample app performs these steps automatically.

- iOS: By default, Tealium includes simulator support for iOS. This works fine for development builds, but will cause errors upon submission to the app store. For this reason, we provide a "Device Only" build without simulator support in the "TealiumDeviceOnly" directory of this repository. Please switch to the "DeviceOnly" build of the plugin prior to App Store submission. The only difference between the 2 plugins is that the ".framework" files for the core iOS SDK have had the simulator support removed. All other Cordova plugin files remain unchanged.

## Known Issues
- (Affects Tealium Collect ONLY - not IQ) Arrays are not processed correctly: Currently, the mechanism used to send data to AudienceStream (VDATA) does not process arrays correctly as a "Set of strings". Additionally, the core iOS and Android libraries do not currently send arrays in the correct format for the VDATA pixel. Both issues are currently being worked on. Arrays ARE correctly passed to Tealium IQ for processing by JavaScript tags. If you need to pass arrays to AudienceStream, the suggested workaround is to disable Tealium Collect in the profile's publish settings, and add the Tealium Collect tag via Tealium IQ.

## Backwards Compatibility
This release includes changes to some API behavior. The following items in particular should be tested after upgrading:

* If you were previously using the ```addVolatile``` and ```addPersistent``` methods, please ensure that you are only storing supported data types specified above
* On iOS, the plugin now runs most of its code on a background thread, except for the initialization method. This should not cause any issues, and should improve performance, but please test thoroughly and report any issues via the GitHub issues page, or via support@tealium.com
* The variable ```cordova_lifecycle```, which was previously sent with all lifecycle events, has now been removed. If you still require this variable, you can create it again by using a "set data values" extension in Tealium IQ, with a rule "if lifecycle_type is populated" to create the variable and add it to all Lifeycle events
* On iOS, Lifecycle sleep events are now tracked as soon as the user either puts the app into the background, or begins to close the app completely. This means when the user brings up the task switcher while an app is running by pressing the home button twice, a sleep event will be generated. If the user cancels the action and goes back into the app, a corresponding wake event will be generated. Previously, sleep events were only created when the user had finished backgrounding the app (by single-press of the home button, or switching to another app). This behavior matches the existing behavior on Android. Be aware that this may cause an increased amount of sleep events to be recorded in your analytics tools, but the numbers will be technically more accurate

## Roadmap
- Improved support for [Tealium AudienceStream](http://tealium.com/products/audiencestream/) to retrieve visitor profile data in addition to just collecting data

## Change Log
- 1.1.0 New NPM package added for deviceonly framework build (works for Android and iOS)
- 1.1.0 Added new persistent data source ```tealium_plugin_version``` with value "Tealium-Cordova-<Version>" e.g. "Tealium-Cordova-1.1.0". Caveat: won't show up on the very first app launch event on iOS, but will be available on subsequent events and subsequent launches
- 1.1.0 Removed ```cordova_lifecycle=true``` variable on lifecycle events
- 1.1.0 Fixed erroneous crash detection on iOS. Previously a crash would be detected on each launch (variable ```lifecycle_diddetectcrash=true```)
- 1.1.0 Fixed Lifecycle calls on iOS. Launch, Wake and Sleep are now tracked correctly 
- 1.1.0 Switched all plugin methods (except init) to run on background threads to improve execution time and remove blocking calls
- 1.1.0 Fixed issues with "DeviceOnly" build which prevented the plugin from building
- 1.1.0 Added support for "TagBridge" Remote Command system for both Android and iOS
- 1.1.0 New xcode build script hook added to automatically add Tealium as an embedded binary on iOS (relies on the ```node-xcode``` package)
- 1.1.0 Core iOS library upgraded to 5.2.0
- 1.1.0 Core Android library upgraded to 5.2.0 - includes fix to enable cookies by default
- 1.1.0 ```addVolatile``` and ```addPersistent``` methods now allow only supported data types (see table above)
- 1.1.0 New API methods added ```getPersistent``` and ```getVolatile``` to retrieve previously-stored variables
- 1.1.0 Updated sample app to include examples of new ```getVolatile``` and ```getPersistent``` methods for different data types
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

Copyright (C) 2012-2017, Tealium Inc.
