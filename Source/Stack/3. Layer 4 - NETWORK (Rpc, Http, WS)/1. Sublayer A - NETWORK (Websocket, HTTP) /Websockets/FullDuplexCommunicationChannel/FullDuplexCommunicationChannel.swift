//
//  FullDuplexCommunicationChannel.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

/// A channel open for communication in both directions, e.g. WebSockets
public protocol FullDuplexCommunicationChannel {
    func sendMessage(_ message: String)
    var messages: Observable<String> { get }
}
