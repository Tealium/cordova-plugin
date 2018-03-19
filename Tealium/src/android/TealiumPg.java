package org.apache.cordova.plugin;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;

import org.apache.cordova.PluginResult;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.tealium.internal.tagbridge.RemoteCommand;
import com.tealium.library.Tealium;
import com.tealium.lifecycle.LifeCycle;

import android.app.Activity;
import android.os.Handler;
import android.util.Log;
import android.app.Application;
import android.os.Build;
import android.content.SharedPreferences;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.Map;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Locale;
import java.util.Set;
import java.lang.reflect.*;

public class TealiumPg extends CordovaPlugin {

    private Map<String, CallbackContext> tagBridgeCallback = new HashMap<String, CallbackContext>(5);
    private final String LOG_TAG = "Tealium-Cordova-1.1.1";
    private boolean isDevBuild = false;
    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final JSONObject arguments = args.getJSONObject(0);
        if (action.equals("init")) {
            // optString("<name>") returns empty string if not present, optString("<name>", null) returns null if not present
            final Tealium instance = Tealium.getInstance(arguments.optString("instance", null));
            // Prevents the log messages reporting errors from re-initialization.
            if(instance != null) {
                return true;
            }
            init(arguments, callbackContext);
            return true;
        } else if(action.equals("track")){
            track(arguments, callbackContext);
            callbackContext.success();
            return true;
        } else if(action.equals("trackLifecycle")){
            trackLifecycle(arguments, callbackContext);
            callbackContext.success();
            return true;
        } else if (action.equals("setPersistent")) {
            set(arguments, callbackContext, "persistent");
            callbackContext.success();
            return true;
        } else if (action.equals("setVolatile")) {
            set(arguments, callbackContext, "volatile");
            callbackContext.success();
            return true;
        } else if (action.equals("getVolatile")) {
            Object val = get(arguments, "volatile");
            if (val instanceof String) {
                callbackContext.success((String) val);    
            } else if (val instanceof JSONArray) {
                callbackContext.success((JSONArray) val);
            } else if (val instanceof JSONObject) {
                callbackContext.success((JSONObject) val);
            } else {
                // not found - return empty string
                callbackContext.success("");
            }
            return true;
        } else if (action.equals("getPersistent")) {
            Object val = get(arguments, "persistent");
            if (val instanceof String) {
                callbackContext.success((String) val);    
            } else if (val instanceof Set) {
                callbackContext.success(stringSetToJsonArray((Set<?>) val));
            } else {
                // not found - return empty string
                callbackContext.success("");
            }
            return true;
        } else if (action.equals("addRemoteCommand")) {
            String remoteCommandName = arguments.optString("commandName");
            Boolean isNewCommand = (tagBridgeCallback.get(remoteCommandName) == null);
            tagBridgeCallback.put(remoteCommandName, callbackContext);
            PluginResult tagBridgePluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
            tagBridgePluginResult.setKeepCallback(true);
            callbackContext.sendPluginResult(tagBridgePluginResult);
            if (isNewCommand) {
                addRemoteCommand(arguments, callbackContext);
            }
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
            if (environmentName!= null && environmentName.equals("dev")) {
                this.isDevBuild = true;
            }
            String collectDispatchURL = arguments.optString("collectDispatchURL", null);
            String collectDispatchProfile = arguments.optString("collectDispatchProfile", null);
            String instanceName = arguments.optString("instance", null);
            String isLifecycleEnabled = arguments.optString("isLifecycleEnabled", "true");
            String dataSourceId = arguments.optString("dataSourceId", null);
            String isCrashReporterEnabled = arguments.optString("isCrashReporterEnabled", "false");
            Tealium.Config config = Tealium.Config.create(app, accountName, profileName, environmentName);
            ArrayList<String> moduleErrors = new ArrayList<>(3);

            String libVersion = "5.4.2";
            String override = this.mobileUrlOverride(accountName, profileName, environmentName, libVersion);
            config.setOverrideTagManagementUrl(override);
            config.setOverridePublishSettingsUrl(override);

            // full URL takes precedence over just the profile.
            if (collectDispatchURL != null){
                config.setOverrideCollectDispatchUrl(collectDispatchURL);
            } else if (collectDispatchProfile != null) {
                config.setOverrideCollectDispatchUrl("https://collect.tealiumiq.com/vdata/i.gif?tealium_account=" + accountName + "&tealium_profile=" + collectDispatchProfile);
            }

            if (isLifecycleEnabled.equals("true")) {
                boolean isAutoTracking = false;
                LifeCycle.setupInstance(instanceName, config, isAutoTracking);
            }
            
            if (dataSourceId != null) {
                config.setDatasourceId(dataSourceId);
            }

            if (isCrashReporterEnabled.equals("true")) {
                try {
                    // using reflection to check if optional crashreporter module is present in the app
                    Class<?> crashReporter = Class.forName("com.tealium.crashreporter.CrashReporter");
                    Class[] cArg = new Class[3];
                    cArg[0] = String.class;
                    cArg[1] = Tealium.Config.class;
                    cArg[2] = boolean.class;
                    Method initCrashReporter = crashReporter.getDeclaredMethod("initialize", cArg);
                    initCrashReporter.setAccessible(true);
                    initCrashReporter.invoke(null, instanceName, config, false);
                    moduleErrors.add("INFO: Tealium Crash Reporter initialized");
                } catch (Exception e) {
                    moduleErrors.add("INFO: Tealium Crash Reporter Module not found");
                    // disable crash testing feature if crash reporter not found
                    this.isDevBuild = false;
                }
            } else {
                // disable crash testing feature if crash reporter not enabled
                this.isDevBuild = false;
            }
            
            // create the Tealium instance using the instance name provided
            final Tealium instance = Tealium.createInstance(instanceName, config);
            if (instance != null){
                setPluginVersion(instance);
            }
            // print any errors for info. e.g. if crash enabled but module not added
            if (moduleErrors.size() > 0) {
                String allErrors = moduleErrors.toString();
                allErrors = allErrors.replace(",", "\n");
                callbackContext.success(allErrors);
            } else {
             callbackContext.success();
            }
        } catch (Throwable t){
            callbackContext.error("Error attempting init call. Check account/profile/environment/instance name combination is valid. Full error: " + t.getMessage());
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

    private Tealium getInstance(String instanceName) {
        return Tealium.getInstance(instanceName);
    }

    private void set (JSONObject arguments, CallbackContext callbackContext, String type){
        try {
            String instanceName = arguments.optString("instance", null);
            String keyName = arguments.optString("keyName", null);
            Object data = arguments.opt("data");
            String remove = arguments.optString("remove", "false");
            if (type != null && type.equals("persistent")) {
                setPersistent(keyName, data, instanceName, remove);
            } else if (type != null && type.equals("volatile")) {
                setVolatile(keyName, data, instanceName, remove);
            }
        } catch (Throwable t){
            Log.e(LOG_TAG, "Error attempting to set persistent or volatile data", t);
        }
    }

    // sets or removes a volatile data source. if "remove" is String true, the data source will be removed
    private void setVolatile (String keyName, Object data, String instanceName, String remove) {
        Tealium instance = getInstance(instanceName);
        if (instance == null) {
            return;
        }
        if (remove != null && remove.equals("true") && keyName != null) {
            instance.getDataSources().getVolatileDataSources().remove(keyName);
        } else if (keyName != null && data != null && (remove == null || remove.equals("false"))) {
            if (data instanceof String || data instanceof JSONArray || data instanceof JSONObject) {
                instance.getDataSources().getVolatileDataSources().put(keyName, data);    
            }
        }
    }

    // sets or removes a volatile data source. if "remove" is String true, the data source will be removed
    private void setPersistent (String keyName, Object data, String instanceName, String remove) {
        Tealium instance = getInstance(instanceName);
        if (instance == null) {
            return;
        }
        if (remove != null && remove.equals("true") && keyName != null) {
            instance.getDataSources().getPersistentDataSources().edit().remove(keyName).apply();
        } else if (keyName != null && data != null && (remove == null || remove.equals("false"))) {
            // checking type before storing as set of strings (array) or string
            if (data instanceof String) {
                instance.getDataSources().getPersistentDataSources().edit().putString(keyName, (String) data).apply();
            } else if (data instanceof JSONArray) {
                Set<String> s = this.jsonArrayToStringSet((JSONArray) data);
                instance.getDataSources().getPersistentDataSources().edit().putStringSet(keyName, s).apply();
            }
        }
    }

    // getter for volatile or persistent data
    private Object get (JSONObject arguments, String type){
    try {
        String instanceName = arguments.optString("instance", null);
        String keyName = arguments.optString("keyName", null);
        final Tealium instance = Tealium.getInstance(instanceName);
        if (instance == null) {

            return null;
        }

        if (keyName == null){
            return null;
        }

        if (type == null) {
            return null;
        }

        if (type.equals("persistent")) {
            SharedPreferences persistent = instance.getDataSources().getPersistentDataSources();
            Map<String, ?> allPersistentData = persistent.getAll();
            return allPersistentData.get(keyName);
        } else if (type.equals("volatile")) {
            return instance.getDataSources().getVolatileDataSources().get(keyName);
        }
        return null;
    } catch (Throwable t){
        Log.e(LOG_TAG, "Error attempting to get persistent or volatile data", t);
        return null;
    }
}

    private void track(JSONObject arguments, CallbackContext callbackContext) {
        try {
            String instanceName = arguments.optString("instance", null);
            String eventType = arguments.optString("eventType", null);
            Map<String, Object> eventData = this.mapJSON(arguments.optJSONObject("eventData"));
            String eventId = (String) eventData.get("link_id");
            String screenTitle = (String) eventData.get("screen_title");
            final Tealium instance = Tealium.getInstance(instanceName);

            if (instanceName == null) {
                Log.e(LOG_TAG, "Instance Name not specified. Please add a valid instance name to the tracking call.");
            } else if (instance == null) {
                Log.e(LOG_TAG, "Library failed to initialize correctly. Please check account/profile/environment combination in init call.");
            } else if (eventType == null) {
                Log.e(LOG_TAG, "Event type not specified. Please pass either link or view as event type");
            } else {
                if (eventType.toLowerCase().equals("view")) {
                    instance.trackView(screenTitle, eventData);
                } else if (eventType.toLowerCase().equals("link")) {
                    instance.trackEvent(eventId, eventData);
                }
                // allows testing of crash tracking in sample app
                if (eventData.containsKey("forceCrash")) {
                    triggerCrash();
                }
            }
        } catch (Throwable t){
            Log.e(LOG_TAG, "Error attempting track call.", t);
        }
    }

    private void addRemoteCommand (JSONObject arguments, final CallbackContext callbackContext) {
        try {
            String instanceName = arguments.optString("instance", null);
            final String remoteCommandName = arguments.optString("commandName", null);
            final Tealium instance = Tealium.getInstance(instanceName);
            if (instanceName == null) {
                Log.e(LOG_TAG, "Instance Name not specified. Please add a valid instance name to the tracking call.");
            } else if (instance == null) {
                Log.e(LOG_TAG, "Library failed to initialize correctly. Please check account/profile/environment combination in init call.");
            } else if (remoteCommandName == null) {
                Log.e(LOG_TAG, "Remote Command Name not specified.");
            } else {  
                instance.addRemoteCommand(new RemoteCommand(remoteCommandName, "Auto generated Cordova remote command") {
                    @Override
                    protected void onInvoke(Response response) throws Exception {
                        JSONObject resp = response.getRequestPayload();
                        String commandReceived = resp.optString("command_id");
                        CallbackContext commandCallback = tagBridgeCallback.get(commandReceived);
                        if (commandCallback != null) {
                            PluginResult result = new PluginResult(PluginResult.Status.OK, resp);
                            result.setKeepCallback(true);
                            commandCallback.sendPluginResult(result);
                        }
                    }
                });
            }
        } catch (Throwable t) {
            Log.e(LOG_TAG, "Error attempting addRemoteCommand call.", t);
        }
    }

    private void doTrackLifecycle(LifeCycle lifeCycle, String eventType, Map<String,Object> eventData) {
        if (lifeCycle != null && eventType != null) {
            if (eventType.toLowerCase().equals("launch")) {
                lifeCycle.trackLaunchEvent(eventData);
            } else if (eventType.toLowerCase().equals("wake")) {
                lifeCycle.trackWakeEvent(eventData);
            } else if (eventType.toLowerCase().equals("sleep")) {
                lifeCycle.trackSleepEvent(eventData);
            }
        } else {
            Log.e(LOG_TAG, "LifeCycle tracking attempted, but instance not initialized yet.");
        }
    }

    private void trackLifecycle(JSONObject arguments, CallbackContext callbackContext) {

        try {
            String instanceName = arguments.optString("instance", null);
            Map<String, Object> eventData;
            String eventType = arguments.optString("eventType", null);
            LifeCycle lifeCycle = null;

            if (instanceName == null) {
                Log.e(LOG_TAG, "LifeCycle tracking attempted, but instanceName argument was null");
                return;
            }

            lifeCycle = LifeCycle.getInstance(instanceName);

            if (lifeCycle == null) {
                Log.e(LOG_TAG, "Tealium instance is not initialized yet. LifeCycle tracking failed.");
            } else {
                if (arguments.optJSONObject("eventData") == null) {
                    eventData = new HashMap<String,Object>(1);
                } else {
                    eventData = this.mapJSON(arguments.optJSONObject("eventData"));
                }
                eventData.put("cordova_lifecycle", "true");
                doTrackLifecycle(lifeCycle, eventType, eventData);
            }
        } catch (Throwable t){
            Log.e(LOG_TAG, "Error attempting trackLifecycle call.", t);
        }
    }

    private void triggerCrash(){
        if (!this.isDevBuild) {
            return;
        }
        final Handler handler = new Handler();
        handler.postDelayed(new Runnable() {
            @Override
            public void run() {
                throw new RuntimeException("Tealium Crash Triggered!");
            }
        }, 1000);

    }

    private Set<String> jsonArrayToStringSet (JSONArray json) {
        Set<String> strSet = new HashSet<String>();
        for (int i = 0; i < json.length(); i++) {
            try {
                strSet.add(json.getString(i));
            } catch (JSONException e) {
                Log.e(LOG_TAG, e.toString());
            }
        }
        return strSet;
    }

    private JSONArray stringSetToJsonArray (Set<?> setToConvert) {
        JSONArray returnArray = new JSONArray();
        for (Object item : setToConvert) {
            if (item instanceof String) {
                returnArray.put(item);
            }
        }
        return returnArray;
    }

    private void setPluginVersion(Tealium instance) {
        if (instance != null){
            instance.getDataSources().getPersistentDataSources().edit().putString("tealium_plugin_version", LOG_TAG).apply();
        }
    }

    private Map<String, Object> mapJSON(JSONObject json) {
        Map<String,Object> mapObject = null;
        Iterator<?> keys = null;
        if (json != null) {
            mapObject = new HashMap<String,Object>(json.length());
            keys = json.keys();
        }

        while(keys != null && keys.hasNext()){
            String key = (String) keys.next();
            Object value = json.opt(key);
            mapObject.put(key,value);
        }
        return mapObject;
    }
}
