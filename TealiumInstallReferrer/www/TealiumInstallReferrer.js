var TealiumInstallReferrer =  {
    setPersistent : function (instance) {
        if (instance === ""){
            return;
        }
        cordova.exec(
            tealium.successCallback, // success callback function
            tealium.errorCallback, // error callback function
            'TealiumPgInstallReferrer', // plugin name
            'setPersistent', // with this action name
            [{                  // and this array of custom arguments to create our entry
                "instance" : instance
            }]
        );
    },
    setVolatile : function (instance) {
        if (instance === ""){
            this.logger(this.privateConfig.severity.ERR, "Instance name was not specified in addPersistent call. Terminating...");
            return;
        }
        cordova.exec(
            tealium.successCallback, // success callback function
            tealium.errorCallback, // error callback function
            'TealiumPgInstallReferrer', // plugin name
            'setVolatile', // with this action name
            [{                  // and this array of custom arguments to create our entry
                "instance" : instance
            }]
        );
    }
}

module.exports = TealiumInstallReferrer;