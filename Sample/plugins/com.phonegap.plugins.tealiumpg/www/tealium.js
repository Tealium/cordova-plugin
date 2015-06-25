var Tealium =  {
	/*
	account : "your-account",
    profile : "your-profile",
    environment : "dev", 
    disableHTTPS : false,
    suppressLogs : true,
    suppressErrors : false
	disableLifeCycleTrack : true 
	*/
    init: function(config) {

		if(typeof config != "object") {
			console.log("Error initializing Tealium: please ensure config is an object of key:value pairs.");
			return;
		}
	
		var messages = [];
	
		if(!('account' in config) || typeof config.account != 'string') {
			messages.push('"account" must be supplied with a string');
		}

		if(!('profile' in config) || typeof config.profile != 'string') {		
			messages.push('"profile" must be supplied with a string');
		}

		if(!('environment' in config) || typeof config.environment != 'string') {
			messages.push('"environment" must be supplied with a string of "dev", "qa", or "prod"');
		}
	
		if(messages.length > 0) {
			console.log("Error initializing Tealium:\r\n\t" + messages.join('\r\n\t'));
			return;
		}
		
        cordova.exec(
            tealium.successCallback, // success callback function
            tealium.errorCallback, // error callback function
            'TealiumPg', // mapped to our native class called "Calendar"
            'init', // with this action name
            [ config ]
        );
    },
    track: function(type,data) {
			if (typeof type != "string"){
				console.log("please make sure type is a string, 'view' or 'link'")
			}
			if (typeof data != "object"){
				console.log("please make sure data is an object of key:value pairs")
			}
			if (typeof data != "object" || typeof type != "string"){
				console.log("please make sure to use tealium.track(String type, Object data)");
				return
			}
        cordova.exec(
            tealium.successCallback, // success callback function
            tealium.errorCallback, // error callback function
            'TealiumPg', // mapped to our native class called "Calendar"
            'track', // with this action name
            [{                  // and this array of custom arguments to create our entry
                "eventType": type,
                "eventData": data,
            }]
        );
    },
    successCallback: function(){
            console.log("tealium call successful");
    },
    errorCallback: function(){
            console.log("Fail, check syntax of tealium.init(String account, String profile, String target) or tealium.track(String type, Object data)");
    }
}

module.exports = Tealium;