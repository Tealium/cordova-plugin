cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
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
    "com.tealium.cordova.compact": "0.9.0"
}
// BOTTOM OF METADATA
});