var Tealium =  {
    // new param config.isLifecycleEnabled
    init: function(config, successCallback) {

		if(typeof config != "object") {
			console.log("Error initializing Tealium: please ensure config is an object of key:value pairs.");
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
            console.log("instance name not specified. using default instance name of tealium_cordova.");
            config.instance = "tealium_cordova";
        }
	
		if (config.isLifecycleEnabled === "false") {
            console.log("Lifecycle tracking has been explicitly disabled.");
        }

        if(messages.length > 0) {
			console.log("Error initializing Tealium:\r\n\t" + messages.join('\r\n\t'));
			return;
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
				console.log("please make sure type is a string, 'view' or 'link'")
			}
			if (typeof data != "object"){
				console.log("please make sure data is an object of key:value pairs")
			}
			if (typeof data != "object" || typeof type != "string"){
				console.log("please make sure to use tealium.track(String type, Object data)");
				return;
			}
            if (typeof instance != "string"){
                console.log("instance name not specified. using default instance name of tealium_cordova.");
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
    successCallback: function(e){
            console.log("tealium call successful");
            console.log(e);
    },
    errorCallback: function(e){
            console.log("Fail, check syntax of tealium.init(String account, String profile, String target) or tealium.track(String type, Object data)");
            console.log(e);
            window.tealium_cordova_error = e;
    }
}

module.exports = Tealium;