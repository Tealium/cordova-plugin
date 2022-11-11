
const Environment = {
    dev: "dev",
    qa: "qa",
    prod: "prod"
}

const Collectors = {
    AppData: "AppData",
    Connectivity: "Connectivity",
    DeviceData: "DeviceData",
    Lifecycle: "Lifecycle",
}

const Dispatchers = {
    Collect: "Collect",
    TagManagement: "TagManagement",
    RemoteCommands: "RemoteCommands"
}

const Expiry = {
    forever: 'forever',
    untilRestart: 'untilRestart',
    session: 'session',
}

const ConsentPolicy = {
    ccpa: 'ccpa',
    gdpr: 'gdpr',
}

const ConsentCategories = {
    analytics: 'analytics',
    affiliates: 'affiliates',
    displayAds: 'display_ads',
    email: 'email',
    personalization: 'personalization',
    search: 'search',
    social: 'social',
    bigData: 'big_data',
    mobile: 'mobile',
    engagement: 'engagement',
    monitoring: 'monitoring',
    crm: 'crm',
    cdp: 'cdp',
    cookieMatch: 'cookiematch',
    misc: 'misc',
}

const TimeUnit = {
    minutes: 'minutes',
    hours: 'hours',
    months: 'months',
    days: 'days'
}

const LogLevel = {
    dev: 'dev',
    qa: 'qa',
    prod: 'prod',
    silent: 'silent'
}

const ConsentExpiry = {
    create: function(time, unit) {
        return {
            time: time,
            unit: unit
        }
    }
}

const RemoteCommand = {
    create: function(id, callback, path, url) {
        return {
            id: id,
            path: path,
            url: url,
            callback: callback
        }
    }
}

const Dispatch = {
    view: function(name, data) {
        return {
            type: "view",
            viewName: name || "",
            dataLayer: data || {}
        };
    },
    event: function(name, data) {
        return {
            type: "event",
            eventName: name || "",
            dataLayer: data || {}
        };
    }
};

const Commands = {
    INITIALIZE: "initialize",
    TRACK: "track",
    TERMINATE: "terminateInstance",
    ADD_DATA: "addData",
    GET_DATA: "getData",
    GATHER_TRACK_DATA: "gatherTrackData",
    REMOVE_DATA: "removeData",
    GET_CONSENT_STATUS: "getConsentStatus",
    SET_CONSENT_STATUS: "setConsentStatus",
    GET_CONSENT_CATEGORIES: "getConsentCategories",
    SET_CONSENT_CATEGORIES: "setConsentCategories",
    JOIN_TRACE: "joinTrace",
    LEAVE_TRACE: "leaveTrace",
    GET_VISITOR_ID: "getVisitorId",
    RESET_VISITOR_ID: "resetVisitorId",
    CLEAR_STORED_VISITOR_IDS: "clearStoredVisitorIds",
    SET_VISITOR_SERVICE_LISTENER: "setVisitorServiceListener",
    SET_VISITOR_ID_LISTENER: "setVisitorIdListener",
    SET_CONSENT_EXPIRY_LISTENER: "setConsentExpiryListener",
    ADD_REMOTE_COMMAND: "addRemoteCommand",
    REMOVE_REMOTE_COMMAND: "removeRemoteCommand",
    REMOVE_LISTENERS: "removeListeners"
}

const PLUGIN_NAME = "TealiumCordova";

let TealiumPlugin = {
    utils: {
        Environment: Environment,
        Collectors: Collectors,
        Dispatchers: Dispatchers,
        Expiry: Expiry,
        ConsentPolicy: ConsentPolicy,
        ConsentCategories: ConsentCategories,
        TimeUnit: TimeUnit,
        Dispatch: Dispatch,
        ConsentExpiry: ConsentExpiry,
        RemoteCommand: RemoteCommand,
        LogLevel: LogLevel
    },
    initialize(config, callback) {
        let self = this;
        cordova.exec(function(e) {
            self.addData({'plugin_name': 'Tealium-Cordova', 'plugin_version': '2.3.0'}, Expiry.forever);
            if (config.remoteCommands) {
                config.remoteCommands.forEach((remoteCommand) => {
                    self.addRemoteCommand(remoteCommand.id, remoteCommand.callback, remoteCommand.path, remoteCommand.url)
                });
            }

            callback(true)
        }, function(e) {
            callback(false)
        }, PLUGIN_NAME, Commands.INITIALIZE, [config])
    },

    track(dispatch) {
        cordova.exec(null, null, PLUGIN_NAME, Commands.TRACK, [dispatch])
    },

    terminateInstance() {
        cordova.exec(null, null, PLUGIN_NAME, Commands.TERMINATE)
    },

    addData(data, expiry) {
        cordova.exec(null, null, PLUGIN_NAME, Commands.ADD_DATA, [data, expiry])
    },

    getData(key, callback) {
        cordova.exec(callback, callback, PLUGIN_NAME, Commands.GET_DATA, [key])
    },

    gatherTrackData(callback) {
        cordova.exec(callback, callback, PLUGIN_NAME, Commands.GATHER_TRACK_DATA)
    },

    removeData(keys) {
        cordova.exec(null, null, PLUGIN_NAME, Commands.REMOVE_DATA, [keys])
    },

    getConsentStatus(callback) {
        cordova.exec(callback, callback, PLUGIN_NAME, Commands.GET_CONSENT_STATUS)
    },

    setConsentStatus(consentStatus) {
        cordova.exec(null, null, PLUGIN_NAME, Commands.SET_CONSENT_STATUS, [consentStatus])
    },

    getConsentCategories(callback) {
        cordova.exec(callback, callback, PLUGIN_NAME, Commands.GET_CONSENT_CATEGORIES)
    },

    setConsentCategories(consentCategories) {
        cordova.exec(null, null, PLUGIN_NAME, Commands.SET_CONSENT_CATEGORIES, [consentCategories])
    },

    joinTrace(id) {
        cordova.exec(null, null, PLUGIN_NAME, Commands.JOIN_TRACE, [id])
    },

    leaveTrace() {
        cordova.exec(null, null, PLUGIN_NAME, Commands.LEAVE_TRACE)
    },

    getVisitorId(callback) {
        cordova.exec(callback, callback, PLUGIN_NAME, Commands.GET_VISITOR_ID)
    },

    resetVisitorId() {
        cordova.exec(null, null, PLUGIN_NAME, Commands.RESET_VISITOR_ID)
    },

    clearStoredVisitorIds() {
        cordova.exec(null, null, PLUGIN_NAME, Commands.CLEAR_STORED_VISITOR_IDS)
    },

    setVisitorServiceListener(callback) {
        cordova.exec(callback, callback, PLUGIN_NAME, Commands.SET_VISITOR_SERVICE_LISTENER)
    },

    setVisitorIdListener(callback) {
        cordova.exec(callback, callback, PLUGIN_NAME, Commands.SET_VISITOR_ID_LISTENER)
    },

    setConsentExpiryListener(callback) {
        cordova.exec(callback, callback, PLUGIN_NAME, Commands.SET_CONSENT_EXPIRY_LISTENER)
    },

    addRemoteCommand(id, callback, path, url) {
        cordova.exec(callback, callback, PLUGIN_NAME, Commands.ADD_REMOTE_COMMAND, [id, path, url])
    },

    removeRemoteCommand(id) {
        cordova.exec(null, null, PLUGIN_NAME, Commands.REMOVE_REMOTE_COMMAND, [id])
    },

    removeListeners() {
        cordova.exec(null, null, PLUGIN_NAME, Commands.REMOVE_LISTENERS)
    }
}

module.exports = TealiumPlugin;
