//
//  DefaultRPCClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultRPCClient: RPCClient, FullDuplexCommunicating {
    
    /// The channel this JSON RPC client utilizes for messaging
    public let channel: FullDuplexCommunicationChannel
    
    public init(channel: FullDuplexCommunicationChannel) {
        self.channel = channel
    }
    
    deinit {
        log.error("💣")
    }
}
