//
//  RPCNotificationError.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-09.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum RPCNotificationError: Swift.Error, Equatable {
    case failedToStartObservingNotification(RPCNotification, subscriberId: SubscriberId)
}
