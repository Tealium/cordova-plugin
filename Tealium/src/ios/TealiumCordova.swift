//
//  TealiumCordova.swift
//  TealiumCordova
//
//  Created by James Keith on 24/05/2021.
//

import Foundation
import TealiumSwift

@objc(TealiumCordova)
class TealiumCordova: CDVPlugin {
    // MARK: Properties

    override func pluginInitialize() {
        TealiumPlugin.commandDelegate = commandDelegate
    }
    
    @objc(initialize:)
    public func initialize(_ command: CDVInvokedUrlCommand) {
        guard let config = command.argument(at: 0) as? [String: Any] else {
            return
        }
        
        TealiumPlugin.initialize(config) { result in
            if result {
                let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: result)
                self.commandDelegate.send(result, callbackId: command.callbackId)
            } else {
                let result = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: result)
                self.commandDelegate.send(result, callbackId: command.callbackId)
            }
        }
    }
    
    @objc(track:)
    public func track(_ command: CDVInvokedUrlCommand) {
        guard let dispatch = command.argument(at: 0) as? [String: Any] else {
            return
        }
        TealiumPlugin.track(dispatch)
    }
        
    @objc(terminateInstance:)
    public func terminateInstance(_ command: CDVInvokedUrlCommand) {
        TealiumPlugin.terminateInstance()
    }

    @objc(addData:)
    public func addData(_ command: CDVInvokedUrlCommand) {
        guard let data = command.argument(at: 0) as? NSDictionary,
              let expiry = command.argument(at: 1) as? String else {
            return
        }
        TealiumPlugin.addToDataLayer(data: data, expiry: expiry)
    }

    @objc(removeData:)
    public func removeData(_ command: CDVInvokedUrlCommand) {
        guard let keys = command.argument(at: 0) as? [String] else {
            return
        }
        TealiumPlugin.removeFromDataLayer(keys: keys)
    }

    @objc(getData:)
    public func getData(_ command: CDVInvokedUrlCommand) {
        guard let key = command.argument(at: 0) as? String,
              let item: Any = TealiumPlugin.getFromDataLayer(key: key) else {
            return
        }
        var result: CDVPluginResult
        
        switch item {
        case let value as String:
            result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: value)
        case let value as Int:
            result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: value)
        case let value as Int32:
            result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: value)
        case let value as UInt:
            result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: value)
        case let value as Double:
            result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: value)
        case let value as Bool:
            result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: value)
        case let value as [Any]:
            result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: value)
        case let value as [AnyHashable: Any]:
            result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: value)
        default:
            result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: nil as String?)
        }
        self.commandDelegate.send(result, callbackId: command.callbackId)
    }

    @objc(addRemoteCommand:)
    public func addRemoteCommand(_ command: CDVInvokedUrlCommand) {
        guard let id = command.argument(at: 0) as? String else {
            return
        }
        let path = command.argument(at: 1) as? String
        let url = command.argument(at: 2) as? String
        TealiumPlugin.addRemoteCommand(id: id, callbackId: command.callbackId, path: path, url: url)
        
        let result = CDVPluginResult(status: CDVCommandStatus_NO_RESULT)
        result?.keepCallback = true
        self.commandDelegate.send(result, callbackId: command.callbackId)
    }

    @objc(removeRemoteCommand:)
    public func removeRemoteCommand(_ command: CDVInvokedUrlCommand) {
        guard let id = command.argument(at: 0) as? String else {
            return
        }
        TealiumPlugin.removeRemoteCommand(id: id)
    }
    
    @objc(getConsentStatus:)
    public func getConsentStatus(_ command: CDVInvokedUrlCommand) {
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: TealiumPlugin.consentStatus)
        self.commandDelegate.send(result, callbackId: command.callbackId)
    }

    @objc(setConsentStatus:)
    public func setConsentStatus(_ command: CDVInvokedUrlCommand) {
        guard let status = command.argument(at: 0) as? String else {
            return
        }
        TealiumPlugin.setConsentStatus(status: status)
    }
    
    @objc(getConsentCategories:)
    public func getConsentCategories(_ command: CDVInvokedUrlCommand) {
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: TealiumPlugin.consentCategories)
        self.commandDelegate.send(result, callbackId: command.callbackId)
    }

    @objc(setConsentCategories:)
    public func setConsentCategories(_ command: CDVInvokedUrlCommand) {
        guard let categories = command.argument(at: 0) as? [String] else {
            return
        }
        TealiumPlugin.setConsentCategories(categories: categories)
    }

    @objc(joinTrace:)
    public func joinTrace(_ command: CDVInvokedUrlCommand) {
        guard let id = command.argument(at: 0) as? String else {
            return
        }
        TealiumPlugin.joinTrace(id: id)
    }

    @objc(leaveTrace:)
    public func leaveTrace(_ command: CDVInvokedUrlCommand) {
        TealiumPlugin.leaveTrace()
    }

    @objc(getVisitorId:)
    public func getVisitorId(_ command: CDVInvokedUrlCommand) {
        guard let visitorId = TealiumPlugin.visitorId else {
            return
        }
        let result = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: visitorId)
        self.commandDelegate.send(result, callbackId: command.callbackId)
    }
    
    @objc(setConsentExpiryListener:)
    public func setConsentExpiryListener(_ command: CDVInvokedUrlCommand) {
        guard let callbackId = command.callbackId else {
            return
        }
        TealiumPlugin.setConsentExpiryListener(callbackId: callbackId)
        
        let result = CDVPluginResult(status: CDVCommandStatus_NO_RESULT)
        result?.keepCallback = true
        self.commandDelegate.send(result, callbackId: command.callbackId)
    }
    
    @objc(setVisitorServiceListener:)
    public func setVisitorServiceListener(_ command: CDVInvokedUrlCommand) {
        guard let callbackId = command.callbackId else {
            return
        }
        TealiumPlugin.setVisitorServiceListener(callbackId: callbackId)
        
        let result = CDVPluginResult(status: CDVCommandStatus_NO_RESULT)
        result?.keepCallback = true
        self.commandDelegate.send(result, callbackId: command.callbackId)
    }
    
    @objc(removeListeners:)
    public func removeListeners(_ command: CDVInvokedUrlCommand) {
        TealiumPlugin.removeListeners()
    }
}
