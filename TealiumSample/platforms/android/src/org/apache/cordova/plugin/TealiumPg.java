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

import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;

public class TealiumPg extends CordovaPlugin {

    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
		if (action.equals("init")) {
			
			// Prevents the log messages reporting errors from re-initialization.
			if(Tealium.isActivated()) {
				return false;
			}
			
			Activity activity = cordova.getActivity();
            final JSONObject arguments = args.getJSONObject(0);
            
			// Tealium API requires use in the main thread.
            init(arguments, callbackContext);
            callbackContext.success(); // Thread-safe.

            return true;
            
		} else if(action.equals("track")){
	          final JSONObject arguments = args.getJSONObject(0);
			  
			  // Tealium API requires use in the main thread.
              track(arguments, callbackContext);
              callbackContext.success(); // Thread-safe.

	          return true;
		}
        return false;
    }

    private void init(JSONObject arguments, CallbackContext callbackContext) {
		try {
		    String accountName = arguments.optString("account");
			String profileName = arguments.optString("profile");
			String environmentName = arguments.optString("environment");
            
            Tealium.Config config = Tealium.Config.create(cordova.getActivity(), accountName, profileName, environmentName)
                .setHTTPSEnabled(arguments.optBoolean("disableHTTPS", true));
            
            if(arguments.optBoolean("suppressErrors", false)) {
                config.setLibraryLogLevel(Tealium.LogLevel.SILENT);
                config.setJavaScriptLogLevel(Tealium.LogLevel.SILENT);
            } else if(arguments.optBoolean("suppressLogs", true)) {
                config.setLibraryLogLevel(Tealium.LogLevel.WARN);
                config.setJavaScriptLogLevel(Tealium.LogLevel.WARN);
            } else {
                config.setLibraryLogLevel(Tealium.LogLevel.VERBOSE);
                config.setJavaScriptLogLevel(Tealium.LogLevel.VERBOSE);
            }
            
            String libVersion = "4.1.1c";
            String override = this.mobileUrlOverride(accountName, profileName, environmentName, libVersion);
            config.setMobileHtmlUrlOverride(override);
            
            Tealium.initialize(config);
            
            Tealium.onResume(cordova.getActivity());
            
		} catch (Throwable t){
			Log.e("Tealium", "Error attempting init call.", t);
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
			String eventType = arguments.optString("eventType");
			Map<String, String> eventData = this.mapJSON(arguments.optJSONObject("eventData"));

			Tealium.track(null, eventData, eventType);
		} catch (Throwable t){
			Log.e("Tealium", "Error attempting track call.", t);
		}
    }
		
	private Map<String, String> mapJSON(JSONObject json) {
		Map<String,String> mapObject = new HashMap<String,String>(json.length());
			
		Iterator<?> keys = json.keys();
			
		while(keys.hasNext()){
			String key = (String)keys.next();
			String value = json.optString(key);
			mapObject.put(key,value);
        }
		return mapObject;
	}
		
	@Override
	public void onResume(boolean multitasking) {
			Tealium.onResume(cordova.getActivity());
	}
		
	@Override
    public void onPause(boolean multitasking) {
			Tealium.onPause(cordova.getActivity());
    }
}

