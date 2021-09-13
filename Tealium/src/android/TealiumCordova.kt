package com.tealium.cordova

import android.app.Application
import com.tealium.core.Logger
import com.tealium.core.Tealium
import com.tealium.core.consent.ConsentCategory
import com.tealium.core.consent.ConsentStatus
import com.tealium.core.consent.toJsonArray
import com.tealium.core.messaging.UserConsentPreferencesUpdatedListener
import com.tealium.lifecycle.isAutoTrackingEnabled
import com.tealium.lifecycle.lifecycle
import com.tealium.remotecommanddispatcher.remoteCommands
import com.tealium.remotecommands.RemoteCommand
import com.tealium.visitorservice.VisitorUpdatedListener
import org.apache.cordova.*
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.lang.Exception

class TealiumCordova @JvmOverloads constructor(
    private var tealium: Tealium? = null,
    private var application: Application? = null
) : CordovaPlugin() {

    private var visitorServiceCallbacks: MutableList<VisitorUpdatedListener> = mutableListOf()
    private var consentExpiryCallbacks: MutableList<UserConsentPreferencesUpdatedListener> =
        mutableListOf()
    private var remoteCommandListeners: MutableMap<String, RemoteCommandListener> = mutableMapOf()
    private var remoteCommandFactories: MutableMap<String, RemoteCommandFactory> = mutableMapOf()

    override fun pluginInitialize() {
        application = cordova.activity.application
    }

    override fun execute(
        action: String?,
        args: JSONArray?,
        callbackContext: CallbackContext?
    ): Boolean {
        var result: Boolean = true

        when (action) {
            INITIALIZE -> {
                args?.optJSONObject(0)?.let {
                    initialize(it, callbackContext)
                } ?: callbackContext?.error("Required TealiumConfig not supplied")
            }
            TERMINATE -> {
                terminateInstance()
            }
            TRACK -> {
                args?.optJSONObject(0)?.let {
                    track(it)
                }
            }
            ADD_DATA -> {
                args?.optJSONObject(0)?.let {
                    val expiry = args.optString(1, "")
                    addData(it, expiry)
                }
            }
            REMOVE_DATA -> {
                args?.optJSONArray(0)?.let {
                    removeData(it)
                }
            }
            GET_DATA -> {
                val key = args?.optString(0) ?: ""
                getData(key, callbackContext)
            }
            GET_CONSENT_STATUS -> {
                getConsentStatus(callbackContext)
            }
            SET_CONSENT_STATUS -> {
                val status = args?.optString(0) ?: ""
                if (!status.isEmpty()) {
                    setConsentStatus(status)
                }
            }
            GET_CONSENT_CATEGORIES -> {
                getConsentCategories(callbackContext)
            }
            SET_CONSENT_CATEGORIES -> {
                args?.optJSONArray(0)?.let {
                    setConsentCategories(it)
                }
            }
            JOIN_TRACE -> {
                val id = args?.optString(0) ?: ""
                if (!id.isEmpty()) {
                    joinTrace(id)
                }
            }
            LEAVE_TRACE -> {
                leaveTrace()
            }
            GET_VISITOR_ID -> {
                getVisitorId(callbackContext)
            }
            ADD_REMOTE_COMMAND -> {
                args?.optString(0)?.let { id ->
                    val path = args?.optString(1)
                    val url = args?.optString(2)
                    addRemoteCommand(id, callbackContext, path, url)
                }
            }
            REMOVE_REMOTE_COMMAND -> {
                args?.optString(0)?.let { id ->
                    removeRemoteCommand(id)
                }
            }
            SET_VISITOR_SERVICE_LISTENER -> {
                callbackContext?.let {
                    setVisitorServiceListener(it)
                }
            }
            SET_CONSENT_EXPIRY_LISTENER -> {
                callbackContext?.let {
                    setConsentExpiryListener(it)
                }
            }
            REMOVE_LISTENERS -> {
                removeListeners()
            }
            else -> {
                result = false
            }
        }

        return result
    }

    fun initialize(config: JSONObject, callbackContext: CallbackContext?) {
        try {
            application?.let { app ->
                config.toTealiumConfig(app)?.let {
                    tealium = Tealium.create(INSTANCE_NAME, it) {
                        if (it.isAutoTrackingEnabled ?: false) {
                            lifecycle?.apply {
                                onActivityResumed(cordova.activity)
                            }
                        }
                        callbackContext?.sendPluginResult(PluginResult(PluginResult.Status.OK))
                    }
                } ?: callbackContext?.error("Exception creating Tealium: Invalid Config")
            } ?: callbackContext?.error("Exception creating Tealium: Application unavailable")
        } catch (ex: Exception) {
            callbackContext?.error("Exception creating Tealium: ${ex.message}")//cba519be-55fd-4e2f-8d7e-7356cbd4d10b
        }
    }

    fun track(dispatch: JSONObject) {
        dispatchFromMap(dispatch).let {
            tealium?.track(it)
        }
    }

    fun terminateInstance() {
        tealium = null
        Tealium.destroy(INSTANCE_NAME)
    }

    fun addData(data: JSONObject, expiryString: String) {
        tealium?.apply {
            data.keys().forEach { key ->

                data.opt(key)?.let { value ->
                    val expiry = expiryFromString(expiryString)
                    when (value) {
                        is String -> dataLayer.putString(key, value, expiry)
                        is Int -> dataLayer.putInt(key, value, expiry)
                        is Long -> dataLayer.putLong(key, value, expiry)
                        is Double -> dataLayer.putDouble(key, value, expiry)
                        is Boolean -> dataLayer.putBoolean(key, value, expiry)
                        is JSONArray -> {
                            if (value.length() <= 0) return

                            if (value.isSingleType()) {
                                when (value.opt(0)) {
                                    is Boolean -> dataLayer.putBooleanArray(
                                        key,
                                        value.toTyped(),
                                        expiry
                                    )
                                    is String -> dataLayer.putStringArray(
                                        key,
                                        value.toTyped(),
                                        expiry
                                    )
                                    is Double -> dataLayer.putDoubleArray(
                                        key,
                                        value.toTyped(),
                                        expiry
                                    )
                                    is Int -> dataLayer.putIntArray(
                                        key,
                                        value.toTyped(),
                                        expiry
                                    )
                                    // Maps/Arrays will be serialized to JSON Strings
                                    else -> dataLayer.putString(
                                        key,
                                        value.toString(),
                                        expiry
                                    )
                                }
                            } else {
                                // Mixed Arrays will be serialized to JSON Strings
                                dataLayer.putString(key, value.toString(), expiry)
                            }
                        }
                        is JSONObject -> {
                            dataLayer.putJsonObject(key, value, expiry)
                        }
                    }
                }

            }
        }
    }

    fun getData(key: String, callbackContext: CallbackContext?) {
        tealium?.dataLayer?.get(key)?.let {
            when (it) {
                is Int -> callbackContext?.sendPluginResult(
                    PluginResult(
                        PluginResult.Status.OK,
                        it
                    )
                )
                is Long -> callbackContext?.sendPluginResult(
                    PluginResult(
                        PluginResult.Status.OK,
                        it.toInt()
                    )
                )
                is String -> {
                    try {
                        // Mixed Arrays and Arrays of Arrays/Objects are serialized to string.
                        // check if we need to deserialize it back here, else return the String value
                        if (it.startsWith("[") && it.endsWith("]")) {
                            callbackContext?.sendPluginResult(
                                PluginResult(
                                    PluginResult.Status.OK,
                                    JSONArray(it)
                                )
                            )
                            return
                        }
                    } catch (jex: JSONException) {
                    }
                    callbackContext?.sendPluginResult(PluginResult(PluginResult.Status.OK, it))
                }
                is Double -> callbackContext?.sendPluginResult(
                    PluginResult(
                        PluginResult.Status.OK,
                        it.toFloat()
                    )
                )
                is Boolean -> callbackContext?.sendPluginResult(
                    PluginResult(
                        PluginResult.Status.OK,
                        it
                    )
                )
                is Array<*> -> callbackContext?.sendPluginResult(
                    PluginResult(
                        PluginResult.Status.OK,
                        JSONArray(it)
                    )
                )
                is JSONObject -> callbackContext?.sendPluginResult(
                    PluginResult(
                        PluginResult.Status.OK,
                        it
                    )
                )
                else -> {
                    callbackContext?.sendPluginResult(
                        PluginResult(
                            PluginResult.Status.OK,
                            it.toString()
                        )
                    )
                }
            }
        } ?: callbackContext?.sendPluginResult(PluginResult(PluginResult.Status.OK))
    }

    fun removeData(keys: JSONArray) {
        tealium?.apply {
            for (i in 0 until keys.length())
                dataLayer.remove(keys.getString(i))
        }
    }

    fun getConsentStatus(callbackContext: CallbackContext?) {
        tealium?.apply {
            callbackContext?.sendPluginResult(
                PluginResult(
                    PluginResult.Status.OK,
                    consentManager.userConsentStatus.value
                )
            )
        }
    }

    fun setConsentStatus(status: String) {
        tealium?.apply {
            consentManager.userConsentStatus = ConsentStatus.consentStatus(status)
        }
    }

    fun getConsentCategories(callbackContext: CallbackContext?) {
        tealium?.apply {
            callbackContext?.sendPluginResult(
                PluginResult(
                    PluginResult.Status.OK,
                    consentManager.userConsentCategories?.toJsonArray() ?: JSONArray()
                )
            )
        }
    }

    fun setConsentCategories(categories: JSONArray) {
        tealium?.apply {
            val categoryStrings: List<String> = categories.toArray().map { it.toString() }
            consentManager.userConsentCategories =
                ConsentCategory.consentCategories(categoryStrings.toSet())
        }
    }

    fun joinTrace(id: String) {
        tealium?.joinTrace(id)
    }

    fun leaveTrace() {
        tealium?.leaveTrace()
    }

    fun getVisitorId(callbackContext: CallbackContext?) {
        callbackContext?.sendPluginResult(
            PluginResult(
                PluginResult.Status.OK,
                tealium?.visitorId ?: ""
            )
        )
    }

    fun setVisitorServiceListener(callbackContext: CallbackContext) {
        val callback = VisitorListener(callbackContext)
        visitorServiceCallbacks.add(callback)

        tealium?.events?.subscribe(callback)
        callbackContext.sendPluginResult(PluginResult(PluginResult.Status.NO_RESULT).apply {
            keepCallback = true
        })
    }

    fun setConsentExpiryListener(callbackContext: CallbackContext) {
        val callback = ConsentListener(callbackContext)
        consentExpiryCallbacks.add(callback)

        tealium?.events?.subscribe(callback)
        callbackContext.sendPluginResult(PluginResult(PluginResult.Status.NO_RESULT).apply {
            keepCallback = true
        })
    }

    fun addRemoteCommand(
        id: String,
        callbackContext: CallbackContext?,
        path: String?,
        url: String?
    ) {
        val remoteCommand: RemoteCommand? =
            remoteCommandFactories[id]?.create() ?: callbackContext?.let { callback ->
                RemoteCommandListener(
                    callback,
                    id,
                    "$id Remote Comand"
                ).also { remoteCommandListeners[id] = it }
            }

        remoteCommand?.let { cmd ->
            tealium?.remoteCommands?.add(remoteCommand, path, url)
            callbackContext?.sendPluginResult(PluginResult(PluginResult.Status.NO_RESULT).apply {
                keepCallback = true
            })
        }

    }

    fun removeRemoteCommand(id: String) {
        // cancel JS callback
        val remoteCommand = remoteCommandListeners.remove(id)
        remoteCommand?.callbackContext?.sendPluginResult(PluginResult(PluginResult.Status.NO_RESULT).apply {
            keepCallback = false
        })

        tealium?.remoteCommands?.remove(id)
    }

    fun removeListeners() {
        tealium?.apply {
            consentExpiryCallbacks.forEach {
                events.unsubscribe(it)
            }
            consentExpiryCallbacks.clear()
            visitorServiceCallbacks.forEach {
                events.unsubscribe(it)
            }
            visitorServiceCallbacks.clear()
        }
    }

    fun registerRemoteCommandFactory(factory: RemoteCommandFactory) {
        if (remoteCommandFactories.containsKey(factory.name)) {
            Logger.qa(
                TEALIUM_TAG,
                "RemoteCammand for name ${factory.name} already registered; overwriting."
            )
        }
        remoteCommandFactories[factory.name] = factory
    }

    companion object {
        const val TEALIUM_TAG = "Tealium-Cordova"
    }
}