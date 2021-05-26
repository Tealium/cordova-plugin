//
//  TealiumCordovaExtensions.swift
//  TealiumCordova
//
//  Created by James Keith on 24/05/2021.
//

import Foundation
import TealiumSwift

extension TealiumPlugin {
    
    public static func tealiumConfig(from dictionary: [String: Any]) -> TealiumConfig? {
        guard let account = dictionary[.account] as? String,
              let profile = dictionary[.profile] as? String,
              let environment = dictionary[.environment] as? String else {
            return nil
        }
        
        let localConfig = TealiumConfig(account: account,
                                        profile: profile,
                                        environment: environment,
                                        dataSource: dictionary[.dataSource] as? String)
        
        if let policyString = dictionary[.consentPolicy] as? String,
           let policy = consentPolicyFrom(policyString) {
            localConfig.consentPolicy = policy
            localConfig.consentLoggingEnabled =  dictionary[.consentLoggingEnabled] as? Bool ?? true
            localConfig.onConsentExpiration = {
                consentExpiryCallbackIds.forEach() { callbackId in
                    let result = CDVPluginResult(status: CDVCommandStatus_OK)
                    result?.keepCallback = true
                    commandDelegate?.send(result, callbackId: callbackId)
                }
            }
        }
        
        if let consentExpiry = dictionary[.consentExpiry] as? [String: Any],
            let time = consentExpiry[.time] as? Int,
            let unit = consentExpiry[.unit] as? String {
            var unitType = TimeUnit.days

            switch unit.lowercased() {
            case TealiumCordovaConstants.minutes:
                    unitType = .minutes
            case TealiumCordovaConstants.hours:
                    unitType = .hours
            case TealiumCordovaConstants.months:
                    unitType = .months
                default:
                    break
            }
            localConfig.consentExpiry = (time: time, unit: unitType)
        }
        
        if let customVisitorId = dictionary[.customVisitorId] as? String {
            localConfig.existingVisitorId = customVisitorId
        }
        
        if let lifecycleAutoTrackingEnabled = dictionary[.lifecycleAutoTrackingEnabled] as? Bool {
            localConfig.lifecycleAutoTrackingEnabled = lifecycleAutoTrackingEnabled
        }
        
        var configDispatchers = [Dispatcher.Type]()
        var configCollectors = [Collector.Type]()
        
        if let dispatchers = dictionary[.dispatchers] as? [String] {
            if dispatchers.contains(TealiumCordovaConstants.tagManagement) {
                configDispatchers.append(Dispatchers.TagManagement)
            }
            
            if dispatchers.contains(TealiumCordovaConstants.collect) {
                configDispatchers.append(Dispatchers.Collect)
            }
            
            if dispatchers.contains(TealiumCordovaConstants.remoteCommands) {
                configDispatchers.append(Dispatchers.RemoteCommands)
                localConfig.remoteAPIEnabled = true
            }
        }
        
        if let collectors = dictionary[.collectors] as? [String] {
            if collectors.contains(TealiumCordovaConstants.appData) {
                configCollectors.append(Collectors.AppData)
            }
            
            if collectors.contains(TealiumCordovaConstants.connectivity) {
                configCollectors.append(Collectors.Connectivity)
            }
            
            if collectors.contains(TealiumCordovaConstants.deviceData) {
                configCollectors.append(Collectors.Device)
            }
            
            if collectors.contains(TealiumCordovaConstants.lifecycle) {
                configCollectors.append(Collectors.Lifecycle)
            }
        }
        
        if let useRemoteLibrarySettings = dictionary[.useRemoteLibrarySettings] as? Bool {
            localConfig.shouldUseRemotePublishSettings = useRemoteLibrarySettings
        }
        
        if let logLevel = dictionary[.logLevel] as? String {
            localConfig.logLevel = logLevelFrom(logLevel)
        }
        
        if let overrideCollectURL = dictionary[.overrideCollectURL] as? String {
            localConfig.overrideCollectURL = overrideCollectURL
        }
        
        if let overrideTagManagementURL = dictionary[.overrideTagManagementURL] as? String {
            localConfig.tagManagementOverrideURL = overrideTagManagementURL
        }
        
        if let overrideCollectBatchURL = dictionary[.overrideCollectBatchURL] as? String {
            localConfig.overrideCollectBatchURL = overrideCollectBatchURL
        }
        
        if let overrideLibrarySettingsURL = dictionary[.overrideLibrarySettingsURL] as? String {
            localConfig.publishSettingsURL = overrideLibrarySettingsURL
        }
        
        localConfig.qrTraceEnabled = dictionary[.qrTraceEnabled] as? Bool ?? true
        localConfig.deepLinkTrackingEnabled = dictionary[.deepLinkTrackingEnabled] as? Bool ?? true
        localConfig.lifecycleAutoTrackingEnabled = dictionary[.lifecycleAutotrackingEnabled] as? Bool ?? true
        
        if dictionary[.visitorServiceEnabled] as? Bool == true {
            configCollectors.append(Collectors.VisitorService)
            localConfig.visitorServiceDelegate = visitorServiceDelegate
        }
        
        localConfig.memoryReportingEnabled = dictionary[.memoryReportingEnabled] as? Bool ?? true
        localConfig.collectors = configCollectors
        localConfig.dispatchers = configDispatchers
        
        return localConfig
    }
    
    public static func consentPolicyFrom(_ policy: String) -> TealiumConsentPolicy? {
        switch policy.lowercased() {
            case TealiumCordovaConstants.ccpa:
                return .ccpa
            case TealiumCordovaConstants.gdpr:
                return .gdpr
            default:
                return nil
        }
    }
    
    public static func expiryFrom(_ expiry: String) -> Expiry {
        switch expiry.lowercased() {
            case TealiumCordovaConstants.forever:
                return .forever
            case TealiumCordovaConstants.restart:
                return .untilRestart
            default:
                return .session
        }
    }
    
    public static func dispatchFrom(_ payload: [String: Any]) -> TealiumDispatch? {
        let type = payload[.type] as? String ?? TealiumCordovaConstants.event
        let dataLayer = payload[.dataLayer] as? [String: Any]
        switch type.lowercased() {
        case TealiumCordovaConstants.view:
            guard let viewName = payload[.viewName] as? String else {
                return nil
            }
            return TealiumView(viewName, dataLayer: dataLayer)
        default:
            guard let eventName = payload[.eventName] as? String else {
                return nil
            }
            return TealiumEvent(eventName, dataLayer: dataLayer)
        }
    }
    
    public static func logLevelFrom(_ logLevel: String) -> TealiumLogLevel {
        switch logLevel.lowercased() {
        case TealiumCordovaConstants.dev:
            return .info
        case TealiumCordovaConstants.qa:
            return .debug
        case TealiumCordovaConstants.prod:
            return .error
        case TealiumCordovaConstants.silent:
            return .silent
        default:
            return .error
        }
    }
    
    public static func remoteCommandFor(_ id: String, commandDelegate: CDVCommandDelegate, callbackId: String) -> RemoteCommand {
        return RemoteCommand(commandId: id, description: nil) { response in
            let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: response.payload)
            result?.keepCallback = true
            commandDelegate.send(result, callbackId: callbackId)
        }
    }
}

extension Dictionary where Key: ExpressibleByStringLiteral {
    subscript(key: TealiumCordovaConstants.Config) -> Value? {
        get {
            return self[key.rawValue as! Key]
        }
    }
    subscript(key: TealiumCordovaConstants.Dispatch) -> Value? {
        get {
            return self[key.rawValue as! Key]
        }
    }
    subscript(key: TealiumCordovaConstants.RemoteCommand) -> Value? {
        get {
            return self[key.rawValue as! Key]
        }
    }
}

class VisitorDelegate: VisitorServiceDelegate {
    private let didUpdate: (([String: Any]) -> Void)
    
    init(didUpdate: @escaping (([String: Any]) -> Void)) {
        self.didUpdate = didUpdate
    }
    
    public func didUpdate(visitorProfile: TealiumVisitorProfile) {
        didUpdate(convert(visitorProfile))
    }
    
    private func convert(_ visitorProfile: TealiumVisitorProfile) -> [String: Any] {
        typealias Visitor = TealiumCordovaConstants.Visitor
        let visit: [String: Any?] = [
            Visitor.dates: visitorProfile.currentVisit?.dates,
            Visitor.booleans: visitorProfile.currentVisit?.booleans,
            Visitor.arraysOfBooleans: visitorProfile.currentVisit?.arraysOfBooleans,
            Visitor.numbers: visitorProfile.currentVisit?.numbers,
            Visitor.arraysOfNumbers: visitorProfile.currentVisit?.arraysOfNumbers,
            Visitor.tallies: visitorProfile.currentVisit?.tallies,
            Visitor.strings: visitorProfile.currentVisit?.strings,
            Visitor.arraysOfStrings: visitorProfile.currentVisit?.arraysOfStrings,
            // Sets cannot be serialized to JSON, so convert to array first
            Visitor.setsOfStrings: visitorProfile.currentVisit?.setsOfStrings.map({ (stringSet) -> [String: [String]] in
                var newValue = [String: [String]]()
                stringSet.forEach {
                    newValue[$0.key] = Array($0.value)
                }
                return newValue
            })
        ]
        let visitor: [String: Any?] = [
            Visitor.audiences: visitorProfile.audiences,
            Visitor.badges: visitorProfile.badges,
            Visitor.dates: visitorProfile.dates,
            Visitor.booleans: visitorProfile.booleans,
            Visitor.arraysOfBooleans: visitorProfile.arraysOfBooleans,
            Visitor.numbers: visitorProfile.numbers,
            Visitor.arraysOfNumbers: visitorProfile.arraysOfNumbers,
            Visitor.tallies: visitorProfile.tallies,
            Visitor.strings: visitorProfile.strings,
            Visitor.arraysOfStrings: visitorProfile.arraysOfStrings,
            // Sets cannot be serialized to JSON, so convert to array first
            Visitor.setsOfStrings: visitorProfile.setsOfStrings.map({ (stringSet) -> [String: [String]] in
                var newValue = [String: [String]]()
                stringSet.forEach {
                    newValue[$0.key] = Array($0.value)
                }
                return newValue
            }),
            Visitor.currentVisit: visit.compactMapValues { $0 }
        ]
        return visitor.compactMapValues({$0})
    }
}
