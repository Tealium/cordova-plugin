cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/cordova-plugin-whitelist/whitelist.js",
        "id": "cordova-plugin-whitelist.whitelist",
        "runs": true
    },
    {
        "file": "plugins/com.tealium.cordova.compact/www/tealium.js",
        "id": "com.tealium.cordova.compact.tealium",
        "clobbers": [
            "window.tealium"
        ]
    },
    {
        "file": "plugins/com.tealium.cordova.compact/www/auto_track.js",
        "id": "com.tealium.cordova.compact.auto_track",
        "clobbers": [
            "window.auto_track"
        ]
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "cordova-plugin-whitelist": "1.0.0",
    "com.tealium.cordova.compact": "0.9.5"
}
// BOTTOM OF METADATA
});