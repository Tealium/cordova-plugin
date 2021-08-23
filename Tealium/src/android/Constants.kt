@file:JvmName("Constants")
package com.tealium.cordova

const val INITIALIZE = "initialize"
const val TRACK = "track"
const val TERMINATE = "terminateInstance"
const val ADD_DATA = "addData"
const val GET_DATA = "getData"
const val REMOVE_DATA = "removeData"
const val GET_CONSENT_STATUS = "getConsentStatus"
const val SET_CONSENT_STATUS = "setConsentStatus"
const val GET_CONSENT_CATEGORIES = "getConsentCategories"
const val SET_CONSENT_CATEGORIES = "setConsentCategories"
const val JOIN_TRACE = "joinTrace"
const val LEAVE_TRACE = "leaveTrace"
const val GET_VISITOR_ID = "getVisitorId"
const val SET_VISITOR_SERVICE_LISTENER = "setVisitorServiceListener"
const val SET_CONSENT_EXPIRY_LISTENER = "setConsentExpiryListener"
const val ADD_REMOTE_COMMAND = "addRemoteCommand"
const val REMOVE_REMOTE_COMMAND = "removeRemoteCommand"
const val REMOVE_LISTENERS = "removeListeners"

const val INSTANCE_NAME: String = "main"

const val KEY_CONFIG_ACCOUNT: String = "account"
const val KEY_CONFIG_PROFILE: String = "profile"
const val KEY_CONFIG_ENV: String = "environment"
const val KEY_CONFIG_DATA_SOURCE: String = "dataSource"
const val KEY_CONFIG_CUSTOM_VISITOR_ID: String = "customVisitorId"
const val KEY_CONFIG_COLLECTORS: String = "collectors"
const val KEY_CONFIG_MODULES: String = "modules"
const val KEY_CONFIG_DISPATCHERS: String = "dispatchers"

const val KEY_TRACK_EVENT_TYPE: String = "type"
const val KEY_TRACK_EVENT_NAME: String = "eventName"
const val KEY_TRACK_VIEW_NAME: String = "viewName"
const val KEY_TRACK_DATALAYER: String = "dataLayer"

const val COLLECTORS_APP = "AppData"
const val COLLECTORS_CONNECTIVITY = "Connectivity"
const val COLLECTORS_DEVICE = "DeviceData"
const val COLLECTORS_TIME = "TimeData"

const val MODULES_LIFECYCLE = "Lifecycle"
const val MODULES_VISITOR_SERVICE = "VisitorService"

const val DISPATCHERS_COLLECT = "Collect"
const val DISPATCHERS_TAG_MANAGEMENT = "TagManagement"
const val DISPATCHERS_REMOTE_COMMANDS = "RemoteCommands"

const val KEY_COLLECT_OVERRIDE_URL = "overrideCollectURL"
const val KEY_COLLECT_OVERRIDE_BATCH_URL = "overrideCollectBatchURL"
const val KEY_COLLECT_OVERRIDE_DOMAIN = "overrideCollectDomain"

const val KEY_SETTINGS_OVERRIDE_URL = "overrideLibrarySettingsURL"
const val KEY_SETTINGS_USE_REMOTE = "useRemoteLibrarySettings"

const val KEY_TAG_MANAGEMENT_OVERRIDE_URL = "overrideTagManagementURL"
const val KEY_QR_TRACE_ENABLED = "qrTraceEnabled"

const val KEY_DEEPLINK_TRACKING_ENABLED = "deepLinkTrackingEnabled"

const val KEY_LOG_LEVEL = "logLevel"

const val KEY_CONSENT_LOGGING_ENABLED = "consentLoggingEnabled"
const val KEY_CONSENT_LOGGING_URL = "consentLoggingURL"
const val KEY_CONSENT_POLICY = "consentPolicy"
const val KEY_CONSENT_EXPIRY = "consentExpiry"
const val KEY_CONSENT_EXPIRY_TIME = "time"
const val KEY_CONSENT_EXPIRY_UNIT = "unit"

const val KEY_LIFECYCLE_AUTO_TRACKING_ENABLED = "lifecycleAutotrackingEnabled"

const val KEY_VISITOR_SERVICE_ENABLED = "visitorServiceEnabled"

const val KEY_REMOTE_COMMANDS_CONFIG = "remoteCommands"
const val KEY_REMOTE_COMMANDS_ID = "id"
const val KEY_REMOTE_COMMANDS_PATH = "path"
const val KEY_REMOTE_COMMANDS_URL = "url"
const val KEY_REMOTE_COMMANDS_CALLBACK = "callback"