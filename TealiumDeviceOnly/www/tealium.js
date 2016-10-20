var Tealium =  {
    // new param config.isLifecycleEnabled
    init: function(config, successCallback) {

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
                            "cordova_lifecycle": "true",
                            "autotracked" : "true"
                        }
                    }]
                );
            }
        }

		if(typeof config != "object") {
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


        if (document && document.addEventListener){
            // launch event
            document.addEventListener("deviceready", function (){
                // to avoid init race conditions, launch event delayed by 700ms
                window.setTimeout(function () {trackLifecycle("launch");}, 700);
            });
            // wake event
            document.addEventListener("resume", function (){
                trackLifecycle("wake");
            });
            // sleep event
            document.addEventListener("pause", function (){
                trackLifecycle("sleep");
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