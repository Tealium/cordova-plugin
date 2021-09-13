
//
//  FirebaseRemoteCommandWrapper.swift
//  tealium-cordova-firebase
//
//  Created by James Keith on 09/09/2021.
//
import Foundation
import TealiumSwift
import TealiumFirebase

//@objc(KochavaRemoteCommandWrapper)
class FirebaseRemoteCommandWrapper: RemoteCommandFactory {
    var name: String = "firebase"
    
    func create() -> RemoteCommand {
        // could pass `configurableSetting` here if required
        return FirebaseRemoteCommand()
    }
}