//
//  RemoteCommandFactory.swift
//  tealium-cordova
//
//  Created by James Keith on 08/04/2021.
//
import Foundation
import TealiumSwift

protocol RemoteCommandFactory {
    var name: String { get }
    func create() -> RemoteCommand
}