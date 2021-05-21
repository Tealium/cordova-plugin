package com.tealium.cordova

import com.tealium.core.Logger
import com.tealium.core.consent.ConsentManagementPolicy
import com.tealium.core.consent.ConsentStatus
import com.tealium.core.consent.UserConsentPreferences
import com.tealium.core.messaging.UserConsentPreferencesUpdatedListener
import com.tealium.example.BuildConfig
import com.tealium.remotecommands.RemoteCommand
import com.tealium.visitorservice.VisitorProfile
import com.tealium.visitorservice.VisitorUpdatedListener
import org.apache.cordova.CallbackContext
import org.apache.cordova.PluginResult
import org.json.JSONException

class VisitorListener(private val callbackContext: CallbackContext) : VisitorUpdatedListener {
    override fun onVisitorUpdated(visitorProfile: VisitorProfile) {
        try {
            VisitorProfile.toFriendlyJson(visitorProfile).let {
                callbackContext.sendPluginResult(PluginResult(PluginResult.Status.OK, it).apply { keepCallback = true })
            }
        } catch (jex: JSONException) {
            Logger.qa(BuildConfig.TEALIUM_TAG, "${jex.message}")
        }
    }
}

class ConsentListener(private val callbackContext: CallbackContext): UserConsentPreferencesUpdatedListener {
    override fun onUserConsentPreferencesUpdated(
        userConsentPreferences: UserConsentPreferences,
        policy: ConsentManagementPolicy
    ) {
        if (userConsentPreferences.consentStatus != ConsentStatus.UNKNOWN) return

        callbackContext.sendPluginResult(PluginResult(PluginResult.Status.OK).apply { keepCallback = true })
    }
}

class RemoteCommandListener(val callbackContext: CallbackContext, id: String, description: String = id) : RemoteCommand(id, description) {
    public override fun onInvoke(response: Response) {
        response.requestPayload.put("command_id", commandName)
        try {
            response.requestPayload?.let {
                val result = PluginResult(PluginResult.Status.OK, it)
                result.keepCallback = true
                callbackContext.sendPluginResult(result)
            }
        } catch (jex: JSONException) {
            Logger.qa(BuildConfig.TEALIUM_TAG, "${jex.message}")
        }
        response.send()
    }
}