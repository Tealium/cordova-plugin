package com.tealium.cordova.remotecommands

import com.tealium.cordova.RemoteCommandFactory
import com.tealium.cordova.TealiumCordova
import com.tealium.remotecommands.RemoteCommand
import com.tealium.remotecommands.firebase.FirebaseRemoteCommand
import org.apache.cordova.*
import org.json.JSONArray

class TealiumFirebase : CordovaPlugin() {

    private val factory: RemoteCommandFactory = FirebaseRemoteCommandFactory()

    override fun pluginInitialize() {
        webView.pluginManager.getPlugin("TealiumCordova")?.let {
            (it as? TealiumCordova)?.registerRemoteCommandFactory(factory)
        }
    }

    internal inner class FirebaseRemoteCommandFactory: RemoteCommandFactory {
        override val name: String = "firebase"

        override fun create(): RemoteCommand {
            return FirebaseRemoteCommand(cordova.activity.application)
        }
    }

    override fun execute(
        action: String?,
        args: JSONArray?,
        callbackContext: CallbackContext?
    ): Boolean {
//        var result: Boolean = true

//        when (action) {
//            "create" -> {
//                args?.optJSONObject(0)?.let {
////                    initialize(it, callbackContext)
//                } ?: callbackContext?.error("Required TealiumConfig not supplied")
//            }
//            else -> {
//                result = false
//            }
//        }

        return true
    }

    companion object {
        const val TEALIUM_TAG = "Tealium-Cordova-Firebase"
    }
}