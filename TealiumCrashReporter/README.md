## Tealium Crash Reporter Plugin

[![License](https://img.shields.io/badge/license-Proprietary-blue.svg?style=flat
           )](https://github.com/Tealium/cordova-plugin/blob/master/LICENSE.txt)
![Platform](https://img.shields.io/badge/platform-android-lightgrey.svg?style=flat
             )
![Language](https://img.shields.io/badge/language-java-orange.svg)


## Documentation

This is a supplementary plugin, designed to be used in conjunction with the Tealium Cordova Plugin. It is available for Android only. If installed alongside the main Tealium plugin, it will pass details of any crashes (uncaught exceptions) occurring in your app to the Tealium Data Layer.

For details of how to implement the plugin, please see the Tealium Learning Community: 

[https://community.tealiumiq.com/t5/Mobile-Libraries/Tealium-for-Cordova/ta-p/17618](https://community.tealiumiq.com/t5/Mobile-Libraries/Tealium-for-Cordova/ta-p/17618)

For full details of the Crash Reporter functionality, please see [Tealium Learning Community](https://community.tealiumiq.com/t5/Tealium-for-Android/Crash-Reporter-Module-for-Android/ta-p/20109).

Please note: adding this plugin does not expose any additional JavaScript APIs; it merely adds the Maven dependency to your app. Configuration of the module is achieved through the main Tealium Cordova Plugin JavaScript API.

## Dependencies

The following dependencies will be automatically added to your app when you implement this plugin:

* Tealium [CrashReporter Module](https://github.com/Tealium/tealium-android/tree/master/Support/CrashReporter)

## License

Use of this software is subject to the terms and conditions of the license agreement contained in the file titled "LICENSE.txt".  Please read the license before downloading or using any of the files contained in this repository. By downloading or using any of these files, you are agreeing to be bound by and comply with the license agreement.

 
---
Copyright (C) 2012-2018, Tealium Inc.