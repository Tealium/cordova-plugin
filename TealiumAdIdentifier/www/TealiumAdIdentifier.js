var TealiumAdIdentifier =  {
    setPersistent : function (instance) {
        if (instance === ""){
            if (window.tealium) {
                logger = window.tealium.getGlobalLogger();
                if (logger && logger.logLevels) {
                    logger.log(logger.logLevels.ERR, "Instance name was not specified in AdIdentifier setPersistent call. Terminating...");
                } 
            }
            return;
        }
        cordova.exec(
            tealium.successCallback, // success callback function
            tealium.errorCallback, // error callback function
            'TealiumPgAdIdentifier', // plugin name
            'setPersistent', // with this action name
            [{                  // and this array of custom arguments to create our entry
                "instance" : instance
            }]
        );
    },
    setVolatile : function (instance) {
        if (instance === ""){
            if (window.tealium) {
                logger = window.tealium.getGlobalLogger();
                if (logger && logger.logLevels) {
                    logger.log(logger.logLevels.ERR, "Instance name was not specified in AdIdentifier setVolatile call. Terminating...");
                } 
            }
            return;
        }
        cordova.exec(
            tealium.successCallback, // success callback function
            tealium.errorCallback, // error callback function
            'TealiumPgAdIdentifier', // plugin name
            'setVolatile', // with this action name
            [{                  // and this array of custom arguments to create our entry
                "instance" : instance
            }]
        );
    }
}

module.exports = TealiumAdIdentifier;