@file:JvmName("Utils")
package com.tealium.cordova


import android.app.Application
import android.util.Log
import com.tealium.collectdispatcher.CollectDispatcher
import com.tealium.collectdispatcher.overrideCollectBatchUrl
import com.tealium.collectdispatcher.overrideCollectDomain
import com.tealium.collectdispatcher.overrideCollectUrl
import com.tealium.core.*
import com.tealium.core.collection.AppCollector
import com.tealium.core.collection.ConnectivityCollector
import com.tealium.core.collection.DeviceCollector
import com.tealium.core.collection.TimeCollector
import com.tealium.core.consent.*
import com.tealium.core.persistence.Expiry
import com.tealium.dispatcher.Dispatch
import com.tealium.dispatcher.TealiumEvent
import com.tealium.dispatcher.TealiumView
import com.tealium.example.BuildConfig
import com.tealium.lifecycle.Lifecycle
import com.tealium.lifecycle.isAutoTrackingEnabled
import com.tealium.remotecommanddispatcher.RemoteCommandDispatcher
import com.tealium.tagmanagementdispatcher.TagManagementDispatcher
import com.tealium.tagmanagementdispatcher.overrideTagManagementUrl
import com.tealium.visitorservice.VisitorProfile
import com.tealium.visitorservice.VisitorService
import org.json.JSONArray
import org.json.JSONException
import org.json.JSONObject
import java.util.*
import java.util.concurrent.TimeUnit

private fun missingRequiredProperty(name: String) {
    Log.d(BuildConfig.TEALIUM_TAG, "Missing required property: $name")
}

fun JSONObject.toTealiumConfig(application: Application): TealiumConfig? {
    val account = optString(KEY_CONFIG_ACCOUNT);
    val profile = optString(KEY_CONFIG_PROFILE);
    val environmentString = optString(KEY_CONFIG_ENV, "");

    if (account.isNullOrBlank()) {
        missingRequiredProperty(KEY_CONFIG_ACCOUNT)
        return null
    }
    if (profile.isNullOrBlank()) {
        missingRequiredProperty(KEY_CONFIG_PROFILE)
        return null
    }

    val environment = try {
        Environment.valueOf(environmentString.toUpperCase(Locale.ROOT) ?: "PROD")
    } catch (iax: IllegalArgumentException) {
        missingRequiredProperty(KEY_CONFIG_ENV)
        Environment.PROD
    }

    val collectors = optJSONArray(KEY_CONFIG_COLLECTORS)?.toCollectorFactories()
    val modules = JSONArray().apply {
        // Visitor Service passed as boolean
        optBoolean(KEY_VISITOR_SERVICE_ENABLED, false).let { vsEnabled ->
            if (vsEnabled) {
                put(MODULES_VISITOR_SERVICE)
            }
        }

        // Lifecycle currently passed in collectors
        optJSONArray(KEY_CONFIG_COLLECTORS)?.let {
            if (it.toArray().contains(MODULES_LIFECYCLE)) {
                put(MODULES_LIFECYCLE)
            }
        }

        // not currently in use; leaving in for possible future extensions
        optJSONArray(KEY_CONFIG_MODULES)?.let { modules ->
            for (i in 0 until modules.length()) {
                put(modules.getString(i))
            }
        }
    }.toModuleFactories()

    val dispatchers = optJSONArray(KEY_CONFIG_DISPATCHERS)?.toDispatcherFactories()

    val config = TealiumConfig(application, account, profile, environment,
        collectors = collectors ?: Collectors.core,
        modules = modules ?: mutableSetOf(),
        dispatchers = dispatchers ?: mutableSetOf())


    config.apply {
        // Data Source Id
        safeGetString(KEY_CONFIG_DATA_SOURCE)?.let {
            dataSourceId = it
        }

        // Collect Settings
        safeGetString(KEY_COLLECT_OVERRIDE_URL)?.let {
            overrideCollectUrl = it
        }
        safeGetString(KEY_COLLECT_OVERRIDE_BATCH_URL)?.let {
            overrideCollectBatchUrl = it
        }
        safeGetString(KEY_COLLECT_OVERRIDE_DOMAIN)?.let {
            overrideCollectDomain = it
        }

        // Library Settings
        safeGetBoolean(KEY_SETTINGS_USE_REMOTE)?.let {
            useRemoteLibrarySettings = it
        }

        safeGetString(KEY_SETTINGS_OVERRIDE_URL)?.let {
            overrideLibrarySettingsUrl = it
        }

        // Tag Management
        safeGetString(KEY_TAG_MANAGEMENT_OVERRIDE_URL)?.let {
            overrideTagManagementUrl = it
        }

        // Deep Links
        safeGetBoolean(KEY_QR_TRACE_ENABLED)?.let {
            qrTraceEnabled = it
        }
        safeGetBoolean(KEY_DEEPLINK_TRACKING_ENABLED)?.let {
            deepLinkTrackingEnabled = it
        }

        // Log Level
        safeGetString(KEY_LOG_LEVEL)?.let {
            Logger.logLevel = LogLevel.fromString(it)
        }

        // Consent
        safeGetBoolean(KEY_CONSENT_LOGGING_ENABLED)?.let {
            consentManagerLoggingEnabled = it
        }
        safeGetString(KEY_CONSENT_LOGGING_URL)?.let {
            consentManagerLoggingUrl = it
        }

        safeGetMap(KEY_CONSENT_EXPIRY)?.let { map ->
            map.getDouble(KEY_CONSENT_EXPIRY_TIME).let { time ->
                map.getString(KEY_CONSENT_EXPIRY_UNIT)?.let { unit ->
                    consentExpiry = consentExpiryFromValues(time.toLong(), unit)
                }
            }
        }

        safeGetString(KEY_CONSENT_POLICY)?.let {
            consentManagerPolicy = consentPolicyFromString(it)
        }

        // Lifecycle
        optBoolean(KEY_LIFECYCLE_AUTO_TRACKING_ENABLED, false)?.let {
            isAutoTrackingEnabled = it
        }
    }

    return config
}

internal fun JSONObject.safeGetString(key: String): String? {
    return if (hasValue(key)) getString(key) else null
}

internal fun JSONObject.safeGetBoolean(key: String): Boolean? {
    return if (hasValue(key)) getBoolean(key) else null
}

internal fun JSONObject.safeGetInt(key: String): Int? {
    return if (hasValue(key)) getInt(key) else null
}

internal fun JSONObject.safeGetDouble(key: String): Double? {
    return if (hasValue(key)) getDouble(key) else null
}

internal fun JSONObject.safeGetArray(key: String): JSONArray? {
    return if (hasValue(key)) getJSONArray(key) else null
}

internal fun JSONObject.safeGetMap(key: String): JSONObject? {
    return if (hasValue(key)) getJSONObject(key) else null
}

/**
 * Checks that a valid, non-null, value of a given type exists at the given key
 */
private fun JSONObject.hasValue(key: String) : Boolean {
    return this.has(key) && !this.isNull(key)
}

fun consentPolicyFromString(name: String): ConsentPolicy? {
    return try {
        ConsentPolicy.valueOf(name.toUpperCase(Locale.ROOT))
    } catch (iax: IllegalArgumentException) {
        null
    }
}

fun consentExpiryFromValues(time: Long, unit: String): ConsentExpiry? {
    if (time <= 0) return null

    val count: Long = if (unit == "months") {
        // No TimeUnit.MONTHS, so needs conversion to days.
        val cal = Calendar.getInstance()
        val today = cal.timeInMillis
        cal.add(Calendar.MONTH, time.toInt())
        (cal.timeInMillis - today) / (1000 * 60 * 60 * 24)
    } else { time }
    return timeUnitFromString(unit)?.let { ConsentExpiry(count, it) }
}

fun timeUnitFromString(unit: String): TimeUnit? {
    return when(unit) {
        "minutes" -> TimeUnit.MINUTES
        "hours" -> TimeUnit.HOURS
        "days" -> TimeUnit.DAYS
        "months" -> TimeUnit.DAYS
        else -> null
    }
}

fun JSONArray.toCollectorFactories(): MutableSet<CollectorFactory> {
    return toArray().mapNotNull { collectorFactoryFromString(it.toString()) }.toMutableSet()
}

fun collectorFactoryFromString(name: String): CollectorFactory? {
    return when (name) {
        COLLECTORS_APP -> AppCollector
        COLLECTORS_CONNECTIVITY -> ConnectivityCollector
        COLLECTORS_DEVICE -> DeviceCollector
        COLLECTORS_TIME -> TimeCollector
        else -> null
    }
}

fun JSONArray.toModuleFactories(): MutableSet<ModuleFactory> {
    return toArray().mapNotNull { moduleFactoryFromString(it.toString()) }.toMutableSet()
}

fun moduleFactoryFromString(name: String): ModuleFactory? {
    return when (name) {
        MODULES_LIFECYCLE -> Lifecycle
        MODULES_VISITOR_SERVICE -> VisitorService
        else -> null
    }
}

fun JSONArray.toDispatcherFactories(): MutableSet<DispatcherFactory> {
    return toArray().mapNotNull { dispatcherFactoryFromString(it.toString()) }.toMutableSet()
}

fun dispatcherFactoryFromString(name: String): DispatcherFactory? {
    return when (name) {
        DISPATCHERS_COLLECT -> CollectDispatcher
        DISPATCHERS_TAG_MANAGEMENT -> TagManagementDispatcher
        DISPATCHERS_REMOTE_COMMANDS -> RemoteCommandDispatcher
        else -> null
    }
}

fun expiryFromString(name: String) = when (name.toLowerCase(Locale.ROOT)) {
    "forever" -> Expiry.FOREVER
    else -> Expiry.SESSION
}

fun dispatchFromMap(map: JSONObject): Dispatch {
    val eventType = map.safeGetString(KEY_TRACK_EVENT_TYPE) ?: DispatchType.EVENT

    return when (eventType.toLowerCase(Locale.ROOT)) {
        DispatchType.VIEW -> TealiumView(map.safeGetString(KEY_TRACK_VIEW_NAME)
            ?: DispatchType.VIEW,
            map.optJSONObject(KEY_TRACK_DATALAYER)?.let { JsonUtils.mapFor(it) })
        else -> TealiumEvent(map.safeGetString(KEY_TRACK_EVENT_NAME)
            ?: DispatchType.EVENT,
            map.optJSONObject(KEY_TRACK_DATALAYER)?.let { JsonUtils.mapFor(it) })
    }
}

fun JSONArray.isSingleType(): Boolean {
    if (this.length() == 0) return true

    val clazz: Class<*> = opt(0).javaClass

    for (i in 0 until length()) {
        if (!clazz.isInstance(opt(i))) return false
    }
    return true
}

fun JSONArray.toArray(): Array<Any> {
    val mutableList: MutableList<Any> = mutableListOf()
    for (i in 0 until this.length()) {
        mutableList.add(get(i))
    }
    return mutableList.toTypedArray()
}

inline fun <reified T : Any> JSONArray.toTyped(): Array<T> {
    return this.toArray().mapNotNull { it as? T }.toTypedArray()
}

private val visitorProfileFriendlyNames = mapOf<String, String>(
    "flags" to "booleans",
    "flag_lists" to "arraysOfBooleans",
    "metrics" to "numbers",
    "metric_lists" to "arraysOfNumbers",
    "metric_sets" to "tallies",
    "properties" to "strings",
    "property_lists" to "arraysOfStrings",
    "property_sets" to "setsOfStrings",
    "current_visit" to "currentVisit"
)

internal fun VisitorProfile.Companion.toFriendlyJson(visitorProfile: VisitorProfile): JSONObject {
    return toJson(visitorProfile).let { visitorJson ->
        visitorJson.apply {
            // Rename the top level keys
            this.renameAll(visitorProfileFriendlyNames)

            this.optJSONObject("currentVisit")?.let { currentVisitJson ->
                // Rename the same keys in current Visit
                currentVisitJson.renameAll(visitorProfileFriendlyNames)
                this.put("currentVisit", currentVisitJson)
            }
        }
    }
}

internal fun JSONObject.renameAll(names: Map<String, String>) {
    names.entries.forEach { entry ->
        this.rename(entry.key, entry.value)
    }
}

internal fun JSONObject.rename(oldKey: String, newKey: String) {
    this.opt(oldKey)?.let {
        this.put(newKey, it)
        this.remove(oldKey)
    }
}