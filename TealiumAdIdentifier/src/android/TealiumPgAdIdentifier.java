package org.apache.cordova.plugin;

import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CallbackContext;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import com.tealium.adidentifier.AdIdentifier;
import android.content.Context;

public class TealiumPgAdIdentifier extends CordovaPlugin {
    
    @Override
    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        final JSONObject arguments = args.getJSONObject(0);
        String instanceName = arguments.optString("instance", null);
        String dataType = action.equals("setPersistent") ? "persistent" : "volatile";
        if (instanceName != null) {
            initAdIdentifier(instanceName, dataType, callbackContext);    
            return true;
        }
        callbackContext.error("Tealium Install Referrer: instance name not provided");
        return false;
    }

    private void initAdIdentifier(String instanceName, String persistentOrVolatile, CallbackContext callbackContext) {
        Context mContext = this.cordova.getActivity().getApplicationContext();
        if ("persistent".equals(persistentOrVolatile)) {
            AdIdentifier.setIdPersistent(instanceName, mContext);
        } else {
            AdIdentifier.setIdVolatile(instanceName, mContext);
        }
        callbackContext.success("Tealium Install Referrer: Finished initialization");
    }
}
