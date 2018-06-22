var Tealium =  {
    init: function(config, successCallback, errorCallback) {
        // will only be called on Android
        function trackLifecycle(event, instance) {
            var i = 0;
            for (i = 0; i < window.tealium.instanceNames.length; i++) {
                cordova.exec(
                    tealium.successCallback, // success callback function
                    tealium.errorCallback, // error callback function
                    'TealiumPg', // plugin name
                    'trackLifecycle', // with this action name
                    [{
                        "instance": window.tealium.instanceNames[i],
                        "eventType": event,
                        "eventData": {
                            "autotracked" : "true"
                        }
                    }]
                );
            }
        }

		if(typeof config !== "object") {
			this.logger(this.privateConfig.severity.ERR, "Error initializing Tealium: please ensure config is an object of key:value pairs.");
			return;
		}

        window.tealium.successCallback = successCallback || tealium.successCallback;

        window.tealium.errorCallback = errorCallback || tealium.errorCallback;
	
		var messages = [];
	
        if (!config.isLifecycleEnabled) {
            config.isLifecycleEnabled = "true";
        }

        if (!config.logLevel || (config.logLevel && !this.isValidLogLevel(config.logLevel))) {
            if (config.environment === "dev") {
                this.setLogLevel(this.logLevels.DEV);
            } else if (config.environment === "qa") {
                this.setLogLevel(this.logLevels.QA);
            } else {
                this.setLogLevel(this.logLevels.PROD);
            }
            this.logger(this.privateConfig.severity.WARN, "logLevel not passed in config object - defaulting to " + (config.environment + "").toUpperCase() + " logLevel");
        } else {
            this.setLogLevel(config.logLevel);
        }

		if(!('account' in config) || typeof config.account != 'string') {
			messages.push('"account" must be supplied with a string');
		}

		if(!('profile' in config) || typeof config.profile != 'string') {		
			messages.push('"profile" must be supplied with a string');
		}

		if(!('environment' in config) || typeof config.environment != 'string') {
			messages.push('"environment" must be supplied with a string of "dev", "qa", or "prod"');
		}

        if (!config.instance) {
            this.logger(this.privateConfig.severity.INFO, "Instance name not specified. Using default instance name of tealium_cordova.");
            config.instance = "tealium_cordova";
        }
	
		if (config.isLifecycleEnabled === "false") {
            this.logger(this.privateConfig.severity.INFO, "Lifecycle tracking has been explicitly disabled.");
        }

        if (config.collectDispatchURL) {
            this.logger(this.privateConfig.severity.INFO, "Tealium: Collect dispatch URL provided was: " +  config.collectDispatchURL);
        }

        if (config.collectDispatchProfile) {
            this.logger(this.privateConfig.severity.INFO, "Tealium: Collect dispatch profile provided was: " + config.collectDispatchProfile);
        }

        if (!config.dataSourceId) {
            this.logger(this.privateConfig.severity.INFO, "Tealium: Optional dataSourceId not provided.");
        } else {
            this.logger(this.privateConfig.severity.INFO, "Tealium: dataSourceId provided was: " + config.dataSourceId);   
        }

        if(messages.length > 0) {
			this.logger(this.privateConfig.severity.ERR, "Error initializing Tealium:\r\n\t" + messages.join('\r\n\t'));
			return;
		}

        /*
         * Lifecycle tracking fix
        */
        // keep track of instances for use in async callbacks
        window.tealium = window.tealium || {};
        window.tealium.instanceNames = window.tealium.instanceNames || [];
        window.tealium.instanceNames.push(config.instance);

        // iOS uses automatic lifecycle tracking
        if (document && document.addEventListener && cordova.platformId && cordova.platformId === "android") {
            // launch event
            document.addEventListener("deviceready", function (){
                // to avoid init race conditions, launch event delayed by 700ms
                window.setTimeout(function () {trackLifecycle("launch");}, 700);
            });
            // wake event
            document.addEventListener("resume", function (){
               window.setTimeout(function () {trackLifecycle("wake");}, 0);
            });
            // sleep event
            document.addEventListener("pause", function (){
                window.setTimeout(function () {trackLifecycle("sleep");}, 0);
            });
        }
		
        cordova.exec(
            tealium.successCallback, // success callback function
            tealium.errorCallback, // error callback function
            'TealiumPg', // plugin name
            'init', // with this action name
            [ config ]
        );
    },
    track: function(type, data, instance) {
			if (typeof type != "string"){
				this.logger(this.privateConfig.severity.WARN, "Please make sure type is a string, 'view' or 'link'");
			}
			if (typeof data != "object"){
				this.logger(this.privateConfig.severity.WARN, "Please make sure data is an object of key:value pairs");
			}
			if (typeof data != "object" || typeof type != "string"){
				this.logger(this.privateConfig.severity.ERR, "Please make sure to use tealium.track(String type, Object data)");
				return;
			}
            if (typeof instance != "string"){
                this.logger(this.privateConfig.severity.INFO, "Instance name not specified. Using default instance name of tealium_cordova.");
                instance = "tealium_cordova";
            }   
        cordova.exec(
            tealium.successCallback, // success callback function
            tealium.errorCallback, // error callback function
            'TealiumPg', // plugin name
            'track', // with this action name
            [{                  // and this array of custom arguments to create our entry
                "eventType": type,
                "eventData": data,
                "instance" : instance
            }]
        );
    },
    trackEvent: function (data, instance) {
        this.track("link", data, instance);
    },
    trackView: function (data, instance){
        if (!data.screen_title) {
            this.logger(this.privateConfig.severity.ERR, "screen_title was missing from the trackView call data. Data will be sent with blank screen_title");
            data.screen_title = "";
        }
        this.track("view", data, instance);
    },
    addVolatile : function (keyName, data, instance) {
        if (keyName == null || data == null) {
            this.logger(this.privateConfig.severity.ERR, "Keyname or data object was not specified in addVolatile call. Terminating...");
            return;
        }
        cordova.exec(
            tealium.successCallback, // success callback function
            tealium.errorCallback, // error callback function
            'TealiumPg', // plugin name
            'setVolatile', // with this action name
            [{                  // and this array of custom arguments to create our entry
                "keyName": keyName,
                "data": data,
                "instance" : instance
            }]
        );
    },
    removeVolatile : function (keyName, instance) {
        if (keyName === "") {
            this.logger(this.privateConfig.severity.ERR, "Keyname or data object was not specified in removeVolatile call. Terminating...");
            return;
        }
        if (instance === ""){
            this.logger(this.privateConfig.severity.ERR, "Instance name was not specified in removeVolatile call. Terminating...");
            return;
        }
      cordova.exec(
        tealium.successCallback, // success callback function
        tealium.errorCallback, // error callback function
        'TealiumPg', // plugin name
        'setVolatile', // with this action name
        [{                  // and this array of custom arguments to create our entry
            "keyName": keyName,
            "instance" : instance,
            "remove" : "true"
        }]
    );  
    },
    addPersistent : function (keyName, data, instance) {
        if (keyName === "" || data === "") {
            this.logger(this.privateConfig.severity.ERR, "Keyname or data object was not specified in addPersistent call. Terminating...");
            return;
        }
        if (instance === ""){
            this.logger(this.privateConfig.severity.ERR, "Instance name was not specified in addPersistent call. Terminating...");
            return;
        }
        cordova.exec(
            tealium.successCallback, // success callback function
            tealium.errorCallback, // error callback function
            'TealiumPg', // plugin name
            'setPersistent', // with this action name
            [{                  // and this array of custom arguments to create our entry
                "keyName": keyName,
                "data": data,
                "instance" : instance
            }]
        );
    },
    removePersistent : function (keyName, instance) {
        if (keyName === "") {
            this.logger(this.privateConfig.severity.ERR, "Keyname or data object was not specified in removePersistent call. Terminating...");
            return;
        }
        if (instance === ""){
            this.logger(this.privateConfig.severity.ERR, "Instance name was not specified in removePersistent call. Terminating...");
            return;
        }
      cordova.exec(
        tealium.successCallback, // success callback function
        tealium.errorCallback, // error callback function
        'TealiumPg', // plugin name
        'setPersistent', // with this action name
        [{                  // and this array of custom arguments to create our entry
            "keyName": keyName,
            "instance" : instance,
            "remove" : "true"
        }]
    );  
    },
    getVolatile : function (keyName, instance, callback) {
        if (keyName === "") {
            this.logger(this.privateConfig.severity.ERR, "Keyname or data object was not specified in getVolatile call. Terminating...");
            return;
        }
        if (instance === ""){
            this.logger(this.privateConfig.severity.ERR, "Instance name was not specified in getVolatile call. Terminating...");
            return;
        }
        if (typeof callback !== "function") {
            this.logger(this.privateConfig.severity.ERR, "Callback function not provided to getVolatile. Terminating...");
            return;    
        }
      cordova.exec(
        function (val) {
            if (val === "") {
                // handle the case on Android where empty string is returned (not possible to return null from plugin result)
                val = null;
            }
            if (callback && callback.call) {
                callback(val); // return the value requested from volatile storage
            }
            tealium.successCallback();
        }, // success callback function
        tealium.errorCallback, // error callback function
        'TealiumPg', // plugin name
        'getVolatile', // with this action name
        [{                  // and this array of custom arguments to create our entry
            "keyName": keyName,
            "instance" : instance
        }]
    );  
    },
    getPersistent : function (keyName, instance, callback) {
        if (keyName === "") {
            this.logger(this.privateConfig.severity.ERR, "Keyname or data object was not specified in getPersistent call. Terminating...");
            return;
        }
        if (instance === ""){
            this.logger(this.privateConfig.severity.ERR, "Instance name was not specified in getPersistent call. Terminating...");
            return;
        }
        if (typeof callback !== "function") {
            this.logger(this.privateConfig.severity.ERR, "Callback function not provided to getPersistent. Terminating...");
            return;    
        }
      cordova.exec(
        function (val) {
            if (val === "") {
                // handle the case on Android where empty string is returned (not possible to return null from plugin result)
                val = null;
            }
            if (callback && callback.call) {
                callback(val); // return the value requested from volatile storage
            }
            tealium.successCallback();
        }, // success callback function
        tealium.errorCallback, // error callback function
        'TealiumPg', // plugin name
        'getPersistent', // with this action name
        [{                  // and this array of custom arguments to create our entry
            "keyName": keyName,
            "instance" : instance
        }]
    );  
    },
    // use getPersistent to retrieve the visitor ID
    getVisitorId: function (instance, callback) {
        var VISITOR_ID_KEYNAME = "tealium_visitor_id";
        this.getPersistent(VISITOR_ID_KEYNAME, instance, callback);
    },
    // Adds a remote command (tagbridge) and passes the response back to the JS side
    addRemoteCommand : function (commandName, instance, callback) {
        if (commandName === "") {
            this.logger(this.privateConfig.severity.ERR, "Command name was not specified in addRemoteCommand call. Terminating...");
            return;
        }
        if (instance === ""){
            this.logger(this.privateConfig.severity.ERR, "Instance name was not specified in addRemoteCommand call. Terminating...");
            return;
        }
        cordova.exec(
            function (val) {
                if (val === "") {
                    // handle the case on Android where empty string is returned (not possible to return null from plugin result)
                    val = null;
                }
                if (callback && callback.call){
                    callback(val); // return the value requested from volatile storage
                }
                tealium.successCallback();
            }, // success callback function
            tealium.errorCallback, // error callback function
            'TealiumPg', // plugin name
            'addRemoteCommand', // with this action name
            [{                  // and this array of custom arguments to create our entry
                "commandName": commandName,
                "instance" : instance
            }]
        );  
    },
    logLevels: {
            DEV: 1,
            QA: 2,
            PROD: 3,
            SILENT: 999
    },
    isValidLogLevel : function (logLevel) {
        return this.logLevels.DEV===logLevel || this.logLevels.QA===logLevel || this.logLevels.PROD===logLevel || this.logLevels.SILENT===logLevel;
    },  
    privateConfig: {
        logLevel: null,
        severity : {
            INFO: 1,
            WARN: 2,
            ERR: 3
        },
        TAG: "Tealium Cordova 1.1.2: ",
        pluginVersion: "1.1.2"
    },
    // usage this.logger(this.logLevels.DEV, "some error message")
    logger: function (severity, message) {
        var privateConfig;
        if (!window.tealium) {
            return;
        }
        privateConfig = window.tealium.privateConfig;
        if (severity >= privateConfig.logLevel) {
            if (severity === privateConfig.severity.INFO) {
                console.log(privateConfig.TAG + message);
            } else if (severity === privateConfig.severity.WARN) {
                console.warn(privateConfig.TAG + message);
            }  else if (severity === privateConfig.severity.ERR) {
                console.error(privateConfig.TAG + message);
            }
        }
    },
    getGlobalLogger: function (){
        var t, logger, logLevels;

        t = window.tealium;
        if (!t) {
            return undefined;
        }
        logger = t && t.logger ? t.logger : undefined;
        if (!logger) {
            return undefined;
        }
        logLevels = t && t.privateConfig && t.privateConfig.severity ? t.privateConfig.severity : undefined;
        if (!logLevels) {
            return undefined;
        }

        return {
            "log" : logger,
            "logLevels" : logLevels
        };
    },
    successCallback: function(e){
        var logger;
        if (window.tealium) {
            logger = window.tealium.getGlobalLogger();
            if (logger && logger.logLevels) {
                logger.log(logger.logLevels.INFO, "Tealium call successful");
                logger.log(logger.logLevels.INFO, e);
            } 
        }

    },
    errorCallback: function(e){
        var logger;
        if (window.tealium) {
            logger = window.tealium.getGlobalLogger();
            if (logger && logger.logLevels) {
                logger.log(logger.logLevels.ERR, "Command failure, check syntax of tealium.init (String account, String profile, String target) or tealium.track(String type, Object data)");
                logger.log(logger.logLevels.ERR, e);
                window.tealium_cordova_error = e;
            }
        }   
    },
    setLogLevel: function (logLevel) {
        this.privateConfig.logLevel = logLevel;
    }
}

module.exports = Tealium;