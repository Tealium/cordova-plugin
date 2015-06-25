//
//  TealiumConstants.h
//  TealiumLibraryGenerator
//
//  Created by Jason Koo on 6/30/14.
//  Copyright (c) 2014 tealium. All rights reserved.
//

#import <Foundation/Foundation.h>

// -----------------------
// *** CURRENT VERSION ***
// -----------------------
#define TealiumLibraryVersion @"4.1.4"

// --------------------
// *** INIT OPTIONS ***
// --------------------
// These supercede any remote settings. The TLDisableLifecycleTracking & TLPauseInit option has been deprecated.  Use the globalCustomData argument in the initShared instance call to add data prior to the first track call
typedef NS_ENUM(NSUInteger, TealiumOptions) {
    TLNone                      = 0,
    TLSuppressLogs              = 1 << 0, /** Suppresses all non-error logs*/
    TLDisableExceptionHandling  = 1 << 1, /** Turns off crash tracking*/
    TLDisableHTTPS              = 1 << 2, /** Switches from HTTPS to HTTP - NOT recommended for production release*/
    TLDisplayVerboseLogs        = 1 << 3, /** Print verbose logs to the console*/
};

// -------------------
// *** CALL TYPES  ***
// -------------------
// Use these constants for call type arguments
extern NSString * const TealiumEventCall;
extern NSString * const TealiumViewCall;

// --------------------------------
// *** RESERVED REMOTE COMMANDS ***
// --------------------------------
extern NSString * const TealiumRRC_RegisterPush;
extern NSString * const TealiumRRC_HTTP;
extern NSString * const TealiumRRC_MobileCompanion;

// ---------------------
// REMOTE RESPONSE CODES
// ---------------------
typedef NS_ENUM(NSInteger, TealiumResponseCodes){
    TealiumRC_Unknown   = 0,
    TealiumRC_Success   = 200,
    TealiumRC_NoContent = 204,
    TealiumRC_Malformed = 400,
    TealiumRC_Failure   = 404,
    TealiumRC_Exception = 555
};

// -----------------
// *** PUSH KEYS ***
// -----------------
extern NSString * const TealiumPSK_Targets;
extern NSString * const TealiumPSK_Alert;
extern NSString * const TealiumPSK_Title;

// ----------------
// *** UDO KEYS ***
// ----------------
// Formerly Data Source Keys. Use these constants to override autotracked UDO variable keys
extern NSString * const TealiumDSK_AccessibilityLabel;
extern NSString * const TealiumDSK_AppId;
extern NSString * const TealiumDSK_AppName;
extern NSString * const TealiumDSK_AppRdns;
extern NSString * const TealiumDSK_AppVersion;
extern NSString * const TealiumDSK_Autotracked;
extern NSString * const TealiumDSK_CallType;
extern NSString * const TealiumDSK_CallEventType;
extern NSString * const TealiumDSK_CallViewType;
extern NSString * const TealiumDSK_Carrier;
extern NSString * const TealiumDSK_CarrierISO;
extern NSString * const TealiumDSK_CarrierMCC;
extern NSString * const TealiumDSK_CarrierMNC;
extern NSString * const TealiumDSK_ConnectionType;
extern NSString * const TealiumDSK_Device;
extern NSString * const TealiumDSK_DeviceArchitecture;
extern NSString * const TealiumDSK_DeviceBatteryLevel;
extern NSString * const TealiumDSK_DeviceCPUType;
extern NSString * const TealiumDSK_DeviceIsCharging;
extern NSString * const TealiumDSK_DeviceLanguage;
extern NSString * const TealiumDSK_DeviceResolution;
extern NSString * const TealiumDSK_DeviceToken;
extern NSString * const TealiumDSK_ExceptionType;
extern NSString * const TealiumDSK_ExceptionName;
extern NSString * const TealiumDSK_ExceptionReason;
extern NSString * const TealiumDSK_ExceptionTrace;
extern NSString * const TealiumDSK_ExcludeClasses;
extern NSString * const TealiumDSK_LibraryVersion;
extern NSString * const TealiumDSK_LifecycleCurrentWakeCount;
extern NSString * const TealiumDSK_LifecycleCurrentLaunchCount;
extern NSString * const TealiumDSK_LifecycleCurrentSleepCount;
extern NSString * const TealiumDSK_LifecycleCurrentTerminateCount;
extern NSString * const TealiumDSK_LifecycleCurrentCrashCount;
extern NSString * const TealiumDSK_LifecycleDayOfWeek;
extern NSString * const TealiumDSK_LifecycleDaysSinceLaunch;
extern NSString * const TealiumDSK_LifecycleDaysSinceUpdate;
extern NSString * const TealiumDSK_LifecycleDaysSinceLastWake;
extern NSString * const TealiumDSK_LifecycleHourOfDayLocal;
extern NSString * const TealiumDSK_LifecycleIsFirstLaunch;
extern NSString * const TealiumDSK_LifecycleIsFirstLaunchUpdate;
extern NSString * const TealiumDSK_LifecycleIsFirstWakeToday;
extern NSString * const TealiumDSK_LifecycleIsFirstWakeMonth;
extern NSString * const TealiumDSK_LifecycleFirstLaunchDate;
extern NSString * const TealiumDSK_LifecycleFirstLaunchDate_MMDDYYYY;
extern NSString * const TealiumDSK_LifecycleLastSimilarCallDate;
extern NSString * const TealiumDSK_LifecyclePriorSecondsAwake;
extern NSString * const TealiumDSK_LifecycleSecondsAwake;
extern NSString * const TealiumDSK_LifecycleTotalWakeCount;
extern NSString * const TealiumDSK_LifecycleTotalLaunchCount;
extern NSString * const TealiumDSK_LifecycleTotalSleepCount;
extern NSString * const TealiumDSK_LifecycleTotalTerminateCount;
extern NSString * const TealiumDSK_LifecycleTotalCrashCount;
extern NSString * const TealiumDSK_LifecycleTotalSecondsAwake;
extern NSString * const TealiumDSK_LifecycleType;
extern NSString * const TealiumDSK_LifecycleUpdateLaunchDate;
extern NSString * const TealiumDSK_LinkId;
extern NSString * const TealiumDSK_ObjectClass;
extern NSString * const TealiumDSK_Orientation;
extern NSString * const TealiumDSK_Origin;              // constant identifying mobile from web
extern NSString * const TealiumDSK_OSVersion;
extern NSString * const TealiumDSK_OverrideUrl;
extern NSString * const TealiumDSK_Platform;
extern NSString * const TealiumDSK_PlatformVersion;
extern NSString * const TealiumDSK_ScreenTitle;
extern NSString * const TealiumDSK_SelectedRow;
extern NSString * const TealiumDSK_SelectedSection;
extern NSString * const TealiumDSK_SelectedValue;
extern NSString * const TealiumDSK_SelectedTitle;
extern NSString * const TealiumDSK_SourceType;
extern NSString * const TealiumDSK_Status;              // TODO: slated for future deprecation
extern NSString * const TealiumDSK_TealiumId;
extern NSString * const TealiumDSK_Timestamp;
extern NSString * const TealiumDSK_TimestampGMT;
extern NSString * const TealiumDSK_TimestampLocal;
extern NSString * const TealiumDSK_TimestampUnix;
extern NSString * const TealiumDSK_UUID;
extern NSString * const TealiumDSK_VideoAirplayActive;
extern NSString * const TealiumDSK_VideoHeight;
extern NSString * const TealiumDSK_VideoMediaType;
extern NSString * const TealiumDSK_VideoPlayableDuration;
extern NSString * const TealiumDSK_VideoPlaybackPercent;
extern NSString * const TealiumDSK_VideoPlaybackRate;
extern NSString * const TealiumDSK_VideoPlaybackTime;
extern NSString * const TealiumDSK_VideoStatus;
extern NSString * const TealiumDSK_VideoSourceType;
extern NSString * const TealiumDSK_VideoTimedMetadata;
extern NSString * const TealiumDSK_VideoURL;
extern NSString * const TealiumDSK_VideoWidth;
extern NSString * const TealiumDSK_ViewWidth;
extern NSString * const TealiumDSK_ViewHeight;
extern NSString * const TealiumDSK_ViewSize;
extern NSString * const TealiumDSK_WasQueued;
extern NSString * const TealiumDSK_WebViewServiceType;
extern NSString * const TealiumDSK_WebViewURL;

@interface TealiumConstants : NSObject

@end
