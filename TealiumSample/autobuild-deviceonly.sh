#!/bin/bash
# author: Craig Rouse, Tealium Inc.
# checks for presence of plugins and platforms, removes old Tealium plugin, re-adds plugin, and then rebuilds the projects
# also changes permissions on directory to current user instead of root (node permissions issue on Mac OSX)
DIR_ANDROID="platforms/android"
DIR_IOS="platforms/ios"
MY_USERNAME=$(whoami)
DIR_IOS_PLUGIN="platforms/ios/TealiumSample/Plugins/com.tealium.cordova.v5"
DIR_ANDROID_PLUGIN="platforms/android/platform_www/plugins/com.tealium.cordova.v5"

if [[ -d $DIR_ANDROID_PLUGIN && -d $DIR_IOS_PLUGIN ]]; then
  echo "***BUILDSCRIPT*** removing tealium cordova plugin"
  cordova plugin rm com.tealium.cordova.v5 
fi

if [ -d $DIR_ANDROID ]; then
  cordova platform rm android
  echo "***BUILDSCRIPT*** removing android cordova project" 
fi

if [ -d $DIR_IOS ]; then

  cordova platform rm ios
  echo "***BUILDSCRIPT*** removing ios cordova project"
fi

cordova platform add android

cordova platform add ios

cordova plugin add ../TealiumDeviceOnly

cordova build ios --device

cordova build android

# echo "***BUILDSCRIPT*** changing permissions"
# echo "***BUILDSCRIPT*** USERNAME = $MY_USERNAME"
# originally required due to bad permissions on my cordova install
# sudo chown -R $MY_USERNAME ../TealiumSample/
echo "***BUILDSCRIPT*** build complete"

exit 0

