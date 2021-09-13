const PLUGIN_NAME = "TealiumFirebase";

const Commands = {
    CREATE: "create"
}

let TealiumFirebase = {
    id: "firebaseAnalytics",
    callback: null,
    path: null,
    url: null,
    create() {
        cordova.exec(null, null, PLUGIN_NAME, Commands.CREATE, [])
        return this
    },
    setPath(path) {
        this["path"] = path
        return this
    },    
    setUrl(url) {
        this["url"] = url
        return this
    },    
}

module.exports = TealiumFirebase;