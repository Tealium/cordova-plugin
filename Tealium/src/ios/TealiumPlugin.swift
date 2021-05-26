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
        
        static var visitorServiceDelegate: VisitorServiceDelegate = VisitorDelegate()
        static var consentExpiryCallback: (([Any]) -> Void)?

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
                if let remoteCommands = self.tealium?.remoteCommands,
                   let remoteCommandsArray = config[.remoteCommands] as? [Any] {
                    
                    let commands = remoteCommandsFrom(remoteCommandsArray)
                    commands.forEach {
                        remoteCommands.add($0)
                    }
                }
            
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
        public static func deleteFromDataLayer(keys: [String]) {
            tealium?.dataLayer.delete(for: keys)
        }

        @objc
        public static func addRemoteCommand(id: String) {
            let remoteCommand = self.remoteCommandFor(id)
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
}
