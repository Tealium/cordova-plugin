
//
//  FirebaseRemoteCommandWrapper.swift
//  tealium-cordova-firebase
//
//  Created by James Keith on 09/09/2021.
//
import Foundation
import TealiumSwift
import TealiumFirebase

class FirebaseRemoteCommandWrapper: RemoteCommandFactory {
    var name: String = "firebaseAnalytics"
    
    func create() -> RemoteCommand {
        return FirebaseRemoteCommand()
    }
}
