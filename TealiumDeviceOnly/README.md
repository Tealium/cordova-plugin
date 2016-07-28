## Tealium Plugin for iOS Device Only Build

This project folder contains a build of the TealiumIOS.framework WITHOUT simulator support.  With this build the run script used to strip out simulator support from all frameworks can be removed.

The included Android build is exactly the same as that found in the Tealium folder and has been left for convenience.

From your Cordova project's root folder, to target this build:
$ cordova plugin add </LOCAL_PATH_TO_TEALIUMDEVICEONLY_PLUGIN_FOLDER/>
