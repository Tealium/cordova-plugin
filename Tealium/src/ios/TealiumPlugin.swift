//
//  TealiumPlugin.swift
//  HelloCordova
//
//  Created by James Keith on 24/05/2021.
//

import Foundation
import TealiumSwift

@objc
class TealiumPlugin: NSObject {
    
    
    static var tealium: Tealium?
    private static var config: TealiumConfig?
    
    static var visitorServiceDelegate: VisitorServiceDelegate = VisitorDelegate(didUpdate: { visitor in
        visitorServiceCallbackIds.forEach() { callbackId in
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: visitor)
            result?.keepCallback = true
            commandDelegate?.send(result, callbackId: callbackId)
        }
    })
    
    static var commandDelegate: CDVCommandDelegate?
    static var consentExpiryCallbackIds = [String]()
    static var visitorServiceCallbackIds = [String]()
    
    @objc
    public static var consentStatus: String {
        get {
            tealium?.consentManager?.userConsentStatus.rawValue ?? "unknown"
        }
    }
    
    @objc
    public static var consentCategories: [String] {
        get {
            var converted = [String]()
            tealium?.consentManager?.userConsentCategories?.forEach {
                converted.append($0.rawValue)
            }
            return converted
        }
    }
    
    @objc
    public static var visitorId: String? {
        get {
            tealium?.visitorId
        }
    }
    
    @objc
    public static func initialize(_ config: [String: Any], _ completion: @escaping (Bool) -> Void) {
        guard let localConfig = tealiumConfig(from: config) else {
            return completion(false)
        }
        TealiumPlugin.config = localConfig.copy
        tealium = Tealium(config: localConfig) { _ in
            completion(true)
        }
    }

    @objc
    public static func track(_ dispatch: [String: Any]) {
        guard let track = dispatchFrom(dispatch) else {
            return
        }
        tealium?.track(track)
    }
    
    @objc
    public static func terminateInstance() {
        guard let config = config else {
            return
        }
        TealiumInstanceManager.shared.removeInstance(config: config)
        tealium = nil
    }

    @objc
    public static func addToDataLayer(data: NSDictionary?, expiry: String) {
        guard let data = data as? [String: Any] else {
            return
        }
        tealium?.dataLayer.add(data: data, expiry: expiryFrom(expiry))
    }

    @objc
    public static func removeFromDataLayer(keys: [String]) {
        tealium?.dataLayer.delete(for: keys)
    }
    
    @objc
    public static func getFromDataLayer(key: String) -> Any? {
        tealium?.dataLayer.all[key]
    }

    @objc
    public static func addRemoteCommand(id: String, callbackId: String) {
        let remoteCommand = self.remoteCommandFor(id, callbackId: callbackId)
        tealium?.remoteCommands?.add(remoteCommand)
    }

    @objc
    public static func removeRemoteCommand(id: String) {
        tealium?.remoteCommands?.remove(commandWithId: id)
    }
    
    @objc
    public static func setConsentStatus(status: String) {
        if status == TealiumCordovaConstants.consented {
            tealium?.consentManager?.userConsentStatus = .consented
        } else {
            tealium?.consentManager?.userConsentStatus = .notConsented
        }
    }
        
    @objc
    public static func setConsentCategories(categories: [String]) {
        tealium?.consentManager?.userConsentCategories = TealiumConsentCategories.consentCategoriesStringArrayToEnum(categories)
    }
    
    @objc
    public static func joinTrace(id: String) {
        tealium?.joinTrace(id: id)
    }
        
    @objc
    public static func leaveTrace() {
        tealium?.leaveTrace()
    }
    
    @objc
    public static func setConsentExpiryListener(callbackId: String) {
        consentExpiryCallbackIds.append(callbackId)
    }
    
    @objc
    public static func setVisitorServiceListener(callbackId: String) {
        visitorServiceCallbackIds.append(callbackId)
    }
    
    @objc
    public static func removeListeners() {
        visitorServiceCallbackIds.forEach { callbackId in
            let result = CDVPluginResult(status: CDVCommandStatus_NO_RESULT)
            result?.keepCallback = false
            commandDelegate?.send(result, callbackId: callbackId)
        }
        visitorServiceCallbackIds.removeAll()
        
        consentExpiryCallbackIds.forEach { callbackId in
            let result = CDVPluginResult(status: CDVCommandStatus_NO_RESULT)
            result?.keepCallback = false
            commandDelegate?.send(result, callbackId: callbackId)
        }
        consentExpiryCallbackIds.removeAll()
    }
}
