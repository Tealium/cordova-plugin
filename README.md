Cordova Plugin 0.9.0
====================

### Brief ###

This plugin provides the means to tag Cordova built applications for the purposes of leveraging [Tealium's tag management platform (Tealium IQ)](http://tealium.com/products/enterprise-tag-management/), which permit [Tealium-enabled mobile apps](http://tealium.com/products/enterprise-tag-management/mobile/) to add, remove or edit analytic services remotely, in real-time, without requiring a code rebuild or new release to take effect.

### Table of Contents ###

- [Requirements](#requirements)
- [Embedded Tealium Libraries](#embedded-tealium-libraries)
- [Add Plugin](#add-plugin)
- [Add Tracking](#add-tracking)
- [Removing Tealium (optional)](#removing-tealium-optional)
- [Known Issues](#known-issues)
- [Change Log](#change-log)

### Requirements ###

* Cordova 5.1.1+

### Embedded Tealium Libraries ###

* Tealium iOS 4.1.10c 
* Tealium Android 4.1.1c

### Add Plugin
From the Command-Line Interface (CLI), first:

1. ```cordova create </PATH_TO_PROJECT>```
2. ```cd in to project```
3. ```cordova platform add <PLATFORM>```
4a. ```cordova plugin add com.tealium.cordova.compact```  OR
4b. ```cordova plugin add </LOCAL_PATH_TO_TEALIUM_PLUGIN/>```
5. ```cordova build <PLATFORM>```

Then init the library in your project:

```javascript
tealium.init({
account : "tealiummobile" 		// CHANGE REQUIRED: Your account.
, profile : "demo" 				// CHANGE REQUIRED: Profile you wish to use.
, environment : "dev" 			// CHANGE REQUIRED: Desired target environment - "dev", "qa", or "prod".
, disableHTTPS : false 			// OPTIONAL: Default is false.
, suppressLogs : true 			// OPTIONAL: Default is true.
, suppressErrors : false 		// OPTIONAL: Default is false, doesn't affect iOS.
});
```

### Add Tracking
The following is an example of how to track events or view changes:

```javascript
tealium.track("view", // "view" or "link"
{ "custom_key" : "custom_val" } // Object containing key-value pairs.
);
```

## Removing Tealium (Optional)
In the CLI, in your Cordova project folder run:
```
cordova plugin remove cordova-plugin-tealium
```

### Known Issues ###

- 0.9.0 Calls may queue in Android until first wake after launch

### Change Log ###

- 0.9.0 Update of older phonegap-plugin to Cordova 5.1.1


------------------------------------------------------

Copyright (C) 2012-2015, Tealium Inc.