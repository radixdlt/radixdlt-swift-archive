//
//  RPCResponseLookingLikeRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct RPCResponseLookingLikeRequest<Params>: Decodable, RPCResposeResultConvertible, RPCNotificationResponseConvertible where Params: Decodable {
    public let params: Params
    public let method: RPCNotification
}
public extension RPCResponseLookingLikeRequest {
    var model: Params { return params }
}

public protocol RPCNotificationResponseConvertible {
    var method: RPCNotification { get }
}

public protocol PotentiallySubscriptionIdentifiable {
    var subscriberIdIfPresent: SubscriberId? { get }
}

public extension PotentiallySubscriptionIdentifiable {
    var subscriberIdIfPresent: SubscriberId? { return nil }
}

extension RPCResponseLookingLikeRequest: PotentiallySubscriptionIdentifiable where Params: PotentiallySubscriptionIdentifiable {
      public var subscriberIdIfPresent: SubscriberId? { return params.subscriberIdIfPresent }
}
