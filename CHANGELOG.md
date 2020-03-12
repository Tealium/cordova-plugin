## Change Log

### 1.1.3
- Upgraded core SDKs to tealium-android 5.7.0 and tealium-ios 5.6.6

### 1.1.2
- Incremented version numbers
- Fixed "Diamond Operator" issue: https://github.com/Tealium/cordova-plugin/issues/31

### 1.1.1
- Added optional CrashReporter module
- Added optional Ad Identifier module
- Added optional Install Referrer module
- Switched Android to use Maven dependency instead of manual file include
- Switched iOS to use CocoaPods dependency instead of manual file include
- Removed build hook for embedded binaries on iOS (no longer required due to switch to CocoaPods)
- Added option to set JavaScript LogLevel (DEV, QA, PROD, SILENT)
- Added error callback to JS calls
- Added full API description to docs
- Fixed [issue](https://github.com/Tealium/cordova-plugin/issues/27) where remote commands were not restored after the webview was reloaded
- Fixed bug where omission of a screen title would cause a "view" to be sent as a "link" on iOS
- Added method for retrieving the Tealium visitor id
- Plugin package id renamed to be consistent with npm package (tealium-cordova-plugin) for easier uninstallation with npm
- Added support for dataSourceId in config object
- Added `trackEvent` and `trackView` methods

### 1.1.0
- Added new persistent data source tealium_plugin_version with value "Tealium-Cordova-" e.g. "Tealium-Cordova-1.1.0". Caveat: won't show up on the very first app launch event on iOS, but will be available on subsequent events and subsequent launches
- Removed cordova_lifecycle=true variable on lifecycle events
- Fixed erroneous crash detection on iOS. Previously a crash would be detected on each launch (variable lifecycle_diddetectcrash=true)
- Fixed Lifecycle calls on iOS. Launch, Wake and Sleep are now tracked correctly
- Switched all plugin methods (except init) to run on background threads to improve execution time and remove blocking calls
- Fixed issues with "DeviceOnly" build which prevented the plugin from building
- Added support for "TagBridge" Remote Command system for both Android and iOS
- New xcode build script hook added to automatically add Tealium as an embedded binary on iOS (relies on the node-xcode package)
- Core iOS library upgraded to 5.2.0
- Core Android library upgraded to 5.2.0 - includes fix to enable cookies by default
- addVolatile and addPersistent methods now allow only supported data types (see table above)
- New API methods added getPersistent and getVolatile to retrieve previously-stored variables
- Updated sample app to include examples of new getVolatile and getPersistent methods for different data types

### 1.0.2
-  Updated sample app to include examples for volatile and persistent data API calls
-  Updated README.md to detail new API calls
-  Added API calls to add/remove persistent data and volatile data
-  Android Only - In previous versions of the plugin, the only valid data type was a string. This was not intended behavior. This has been corrected to now accept the data type passed in (String, JSON Object or Array)
-  Added option to override the URL for the Tealium Collect dispatch service (AudienceStream). Previously all calls went to the "main" profile and there was no possibility to override this. This is passed as one of two arguments at compile time (see above notes)
-  Upgraded iOS core library to 5.0.4
-  Upgraded Android core library to 5.0.4
-  Fixed lifecycle tracking on iOS by switching to using Cordova lifecycle events instead of native Android events
-  Fixed lifecycle tracking on Android by switching to using Cordova lifecycle events instead of native Android events
-  Minor optimizations/refactoring in the Java/Objective-C plugin code

### 1.0.1
-  Upgraded core libraries to Android 5.0.2 and iOS 5.0.3 respectively
-  Added lifecycle tracking by default to Android and iOS & additional config option to disable lifecycle tracking
-  Added option to override the init successCallback function (see pull request https://github.com/Tealium/cordova-plugin/pull/8/commits/70ca605393119bac36a7ba66f2ec205a52edf324)

### 0.9.6
-  Multiton pattern now fully supported (allows multiple instances of IQ to run in the same app)
-  Upgraded to use new Tealium core libraries for Android and iOS (v5.0.0 and 5.0.1 respectively)
