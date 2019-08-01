//
//  AtomSubmitAndSubscribeRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct GetAtomStatusRequest: Encodable {
    public let atomIdentifier: AtomIdentifier
}

// MARK: - Encodable
public extension GetAtomStatusRequest {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(atomIdentifier.stringValue, forKey: .atomIdentifier)
    }
    
    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case atomIdentifier = "aid"
    }
}

public struct GetAtomStatusNotificationRequest: Encodable {
    public let atomIdentifier: AtomIdentifier
    public let subscriberId: SubscriberId
}

// MARK: - Encodable
public extension GetAtomStatusNotificationRequest {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(atomIdentifier.stringValue, forKey: .atomIdentifier)
        try container.encode(subscriberId, forKey: .subscriberId)
    }
    
    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case atomIdentifier = "aid"
        case subscriberId
    }
}

public struct CloseAtomStatusNotificationRequest: Encodable {
    public let subscriberId: SubscriberId
}

public struct GetAtomRequest: Encodable {
    public let atomHashIdentifier: HashEUID
}

// MARK: - Encodable
public extension GetAtomRequest {
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(atomHashIdentifier.stringValue, forKey: .atomHashIdentifier)
    }
    
    // MARK: - CodingKeys
    enum CodingKeys: String, CodingKey {
        case atomHashIdentifier = "hid"
    }
}
