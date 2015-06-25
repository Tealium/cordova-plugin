cordova.define('cordova/plugin_list', function(require, exports, module) {
module.exports = [
    {
        "file": "plugins/com.phonegap.plugins.tealiumpg/www/tealium.js",
        "id": "com.phonegap.plugins.tealiumpg.tealium",
        "clobbers": [
            "window.tealium"
        ]
    },
    {
        "file": "plugins/com.phonegap.plugins.tealiumpg/www/auto_track.js",
        "id": "com.phonegap.plugins.tealiumpg.auto_track",
        "clobbers": [
            "window.auto_track"
        ]
    }
];
module.exports.metadata = 
// TOP OF METADATA
{
    "com.phonegap.plugins.tealiumpg": "1.0.0"
}
// BOTTOM OF METADATA
});