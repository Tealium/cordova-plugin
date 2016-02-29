package org.apache.cordova.plugin;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.CordovaInterface;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.tealium.library.Tealium;

import android.content.Context;
import android.app.Activity;
import android.os.AsyncTask;
import android.os.Build;
import android.util.Log;
import android.app.Application;

import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;

public class TealiumPg extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final JSONObject arguments = args.getJSONObject(0);
        if (action.equals("init")) {
            // optString("<name>") returns empty string if not present, optString("<name>", null) returns null if not present
            final Tealium instance = Tealium.getInstance(arguments.optString("instance", null));
            // Prevents the log messages reporting errors from re-initialization.
            if(instance != null) {
                return false;
            }
            
            // Tealium API requires use in the main thread.
            init(arguments, callbackContext);
            callbackContext.success(); // Thread-safe.

            return true;
            
        } else if(action.equals("track")){
              // Tealium API requires use in the main thread.
              track(arguments, callbackContext);
              callbackContext.success(); // Thread-safe.

              return true;
        }
        return false;
    }

    private void init(JSONObject arguments, CallbackContext callbackContext) {
        try {
            Activity activity = cordova.getActivity();
            // need a reference to the application to instantiate Tealium library
            Application app = activity.getApplication();
            String accountName = arguments.optString("account", null);
            String profileName = arguments.optString("profile", null);
            String environmentName = arguments.optString("environment", null);
            String instanceName = arguments.optString("instance", null);
            
            Tealium.Config config = Tealium.Config.create(app, accountName, profileName, environmentName);
            
            String libVersion = "5.0.0";
            String override = this.mobileUrlOverride(accountName, profileName, environmentName, libVersion);
            config.setOverrideTagManagementUrl(override);
            config.setOverridePublishSettingsUrl(override);
            
            // create the Tealium instance using the instance name provided
            Tealium.createInstance(instanceName, config);
        } catch (Throwable t){
            Log.e("Tealium", "Error attempting init call. Check account/profile/environment/instance name combination is valid.", t);
        }
    }
    
    private String mobileUrlOverride(String accountName, String profileName, String environmentName, String libVersion){
        
        return String.format(Locale.ROOT, "https://tags.tiqcdn.com/utag/%s/%s/%s/mobile.html?%s=%s&%s=%s&%s=%s",
                             accountName,
                             profileName,
                             environmentName,
                             "platform", "android_cordova",
                             "library_version", libVersion,
                             "os_version", android.os.Build.VERSION.RELEASE);
    }
        
    private void track(JSONObject arguments, CallbackContext callbackContext) {
        try { 
            String instanceName = arguments.optString("instance", null);
            String eventType = arguments.optString("eventType", null);
            Map<String, String> eventData = this.mapJSON(arguments.optJSONObject("eventData"));
            String eventId = eventData.get("link_id");
            String screenTitle = eventData.get("screen_title");
            final Tealium instance = Tealium.getInstance(instanceName);

            if (instanceName == null) {
                Log.e("Tealium", "Instance Name not specified. Please add a valid instance name to the tracking call.");
            } else if (instance == null) {
                Log.e("Tealium", "Library failed to initialize correctly. Please check account/profile/environment combination in init call.");
            } else if (eventType == null) {
                Log.e("Tealium", "Event type not specified. Please pass either link or view as event type");
            } else {
                if (eventType.toLowerCase().equals("view")) {
                    instance.trackView(screenTitle, eventData);
                } else if (eventType.toLowerCase().equals("link")) {
                    instance.trackEvent(eventId, eventData);
                }
            }
        } catch (Throwable t){
            Log.e("Tealium", "Error attempting track call.", t);
        }
    }
        
    private Map<String, String> mapJSON(JSONObject json) {
        Map<String,String> mapObject = new HashMap<String,String>(json.length());
        Iterator<?> keys = json.keys();
            
        while(keys.hasNext()){
            String key = (String)keys.next();
            String value = json.optString(key, null);
            mapObject.put(key,value);
        }
        return mapObject;
    }
}
