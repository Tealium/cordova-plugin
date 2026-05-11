//
//  RemoteCommandFactory.swift
//  tealium-cordova
//
//  Created by James Keith on 08/04/2021.
//
import Foundation
#if canImport(TealiumSwift)
import TealiumSwift
#else
import TealiumCore
import TealiumRemoteCommands
#endif

public protocol RemoteCommandFactory {
    var name: String { get }
    func create() -> RemoteCommand
}