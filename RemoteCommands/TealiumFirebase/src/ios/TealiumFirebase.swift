//
//  TealiumFirebase.swift
//  TealiumCordova
//
//  Created by James Keith on 09/09/2021.
//

import Foundation
import TealiumSwift

@objc(TealiumFirebase)
class TealiumFirebase: CDVPlugin {
    // MARK: Properties
    var factory : FirebaseRemoteCommandWrapper?
    
    override func pluginInitialize() {
        // late initialization - had errors when initializing the field above.
        factory = FirebaseRemoteCommandWrapper()
        TealiumPlugin.registerRemoteCommandFactory(factory!)
    }
    
    @objc(create:)
    public func create(_ command: CDVInvokedUrlCommand) {
        self.commandDelegate.send(CDVPluginResult(status: CDVCommandStatus_NO_RESULT), callbackId: command.callbackId)
        
    }
}
