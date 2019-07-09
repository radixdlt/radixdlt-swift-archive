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
    
    // swiftlint:disable:next identifier_name
    private var WARNING_MANUALLY_CREATING_RETAIN_CYCLE_REMOVE_THIS︕！WWHEN_YOU_SEE_THIS︕！: DefaultRPCClient!
    
    public init(channel: FullDuplexCommunicationChannel) {
        self.channel = channel
        WARNING_MANUALLY_CREATING_RETAIN_CYCLE_REMOVE_THIS︕！WWHEN_YOU_SEE_THIS︕！ = self
    }
    
    deinit {
        log.warning("🧨")
    }
}
