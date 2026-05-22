
//
//  FirebaseRemoteCommandWrapper.swift
//  tealium-cordova-firebase
//
//  Created by James Keith on 09/09/2021.
//
import Foundation
#if canImport(Cordova)
import Cordova
#endif
#if canImport(TealiumSwift)
import TealiumSwift
#else
import TealiumCore
import TealiumRemoteCommands
import tealium_cordova_plugin
#endif
import TealiumFirebase

class FirebaseRemoteCommandWrapper: RemoteCommandFactory {
    var name: String = "firebaseAnalytics"
    
    func create() -> RemoteCommand {
        return FirebaseRemoteCommand()
    }
}
