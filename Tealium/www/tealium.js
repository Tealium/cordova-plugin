var Tealium =  {
    // new param config.isLifecycleEnabled
    init: function(config, successCallback) {
        // will only be called on Android
        function trackLifecycle(event, instance) {
            var i = 0;
            for (i = 0; i < window.tealium.instanceNames.length; i++) {
                cordova.exec(
                    onSuccess, // success callback function
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
			console.log("Tealium: Error initializing Tealium: please ensure config is an object of key:value pairs.");
			return;
		}

        var onSuccess = successCallback || tealium.successCallback;
	
		var messages = [];
	
        if (!config.isLifecycleEnabled) {
            config.isLifecycleEnabled = "true";
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
            console.log("Tealium: instance name not specified. using default instance name of tealium_cordova.");
            config.instance = "tealium_cordova";
        }
	
		if (config.isLifecycleEnabled === "false") {
            console.log("Tealium: Lifecycle tracking has been explicitly disabled.");
        }

        if (config.collectDispatchURL) {
            console.log("Tealium: Collect dispatch URL provided was: ", config.collectDispatchURL);
        }

        if (config.collectDispatchProfile) {
            console.log("Tealium: Collect dispatch profile provided was: ", config.collectDispatchProfile);
        }

        if(messages.length > 0) {
			console.log("Tealium: Error initializing Tealium:\r\n\t" + messages.join('\r\n\t'));
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
            onSuccess, // success callback function
            tealium.errorCallback, // error callback function
            'TealiumPg', // plugin name
            'init', // with this action name
            [ config ]
        );
    },
    track: function(type, data, instance) {
			if (typeof type != "string"){
				console.log("Tealium: please make sure type is a string, 'view' or 'link'")
			}
			if (typeof data != "object"){
				console.log("Tealium: please make sure data is an object of key:value pairs")
			}
			if (typeof data != "object" || typeof type != "string"){
				console.log("Tealium: please make sure to use tealium.track(String type, Object data)");
				return;
			}
            if (typeof instance != "string"){
                console.log("Tealium: instance name not specified. using default instance name of tealium_cordova.");
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
    addVolatile : function (keyName, data, instance) {
        if (keyName == null || data == null) {
            console.log("Tealium: keyname or data object was not specified in addVolatile call. Terminating...");
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
            console.log("Tealium: keyname or data object was not specified in removeVolatile call. Terminating...");
            return;
        }
        if (instance === ""){
            console.log("Tealium: instance name was not specified in removeVolatile call. Terminating...");
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
            console.log("Tealium: keyname or data object was not specified in addPersistent call. Terminating...");
            return;
        }
        if (instance === ""){
            console.log("Tealium: instance name was not specified in addPersistent call. Terminating...");
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
            console.log("Tealium: keyname or data object was not specified in addPersistent call. Terminating...");
            return;
        }
        if (instance === ""){
            console.log("Tealium: instance name was not specified in addPersistent call. Terminating...");
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
            console.log("Tealium: keyname or data object was not specified in addPersistent call. Terminating...");
            return;
        }
        if (instance === ""){
            console.log("Tealium: instance name was not specified in addPersistent call. Terminating...");
            return;
        }
        if (typeof callback !== "function") {
            console.log("Tealium: callback function not provided to getVolatile. Terminating...");
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
            console.log("Tealium: keyname or data object was not specified in addPersistent call. Terminating...");
            return;
        }
        if (instance === ""){
            console.log("Tealium: instance name was not specified in addPersistent call. Terminating...");
            return;
        }
        if (typeof callback !== "function") {
            console.log("Tealium: callback function not provided to getVolatile. Terminating...");
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
    // Adds a remote command (tagbridge) and passes the response back to the JS side
    addRemoteCommand : function (commandName, instance, callback) {
        if (commandName === "") {
            console.log("Tealium: keyname or data object was not specified in addPersistent call. Terminating...");
            return;
        }
        if (instance === ""){
            console.log("Tealium: instance name was not specified in addPersistent call. Terminating...");
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
    successCallback: function(e){
            console.log("Tealium: tealium call successful");
            console.log(e);
    },
    errorCallback: function(e){
            console.log("Tealium: Fail, check syntax of tealium.init(String account, String profile, String target) or tealium.track(String type, Object data)");
            console.log(e);
            window.tealium_cordova_error = e;
    }
}

module.exports = Tealium;