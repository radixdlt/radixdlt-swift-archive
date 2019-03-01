//
//  MessageParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct MessageParticle: ParticleModelConvertible, Accountable {
    
    public static let type = RadixModelType.messageParticle
    
    public let from: Address
    public let to: Address
    public let metaData: MetaData
    public let payload: Data
    
    public init(from: Address, to: Address, payload: Data, metaData: MetaData = [:]) {
        self.from = from
        self.to = to
        self.metaData = metaData
        self.payload = payload
    }
}

// MARK: - ParticleConvertible
public extension MessageParticle {
    var particleType: ParticleType {
        return .message
    }
}

// MARK: - Convenience init
public extension MessageParticle {
    public init(from: Address, to: Address, message: String, includeTimeNow: Bool = true) {
        guard let messageData = message.data(using: .utf8) else {
            incorrectImplementation("Should always be able to encode a string")
        }
        let metaData: MetaData = includeTimeNow ? .timeNow : [:]
        self.init(from: from, to: to, payload: messageData, metaData: metaData)
    }
}

// MARK: - Accountable
public extension MessageParticle {
    var addresses: Addresses {
        return Addresses([from, to])
    }
}

// MARK: Codable
public extension MessageParticle {
    public enum CodingKeys: String, RadixModelKey {
        public static let modelType = CodingKeys.type
        case type = "serializer"

        case from = "source"
        case to = "destination"
        case payload = "data"
        case metaData
    }
    
    // swiftlint:disable:next function_body_length
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try MessageParticle.verifyType(container: container)
        
        let from = try container.decode(Address.self, forKey: .from)
        let to = try container.decode(Address.self, forKey: .to)
        let payloadBase64 = try container.decode(Base64String.self, forKey: .payload)
        let metaData = try container.decode(MetaData.self, forKey: .metaData)
        
        self.init(
            from: from,
            to: to,
            payload: payloadBase64.asData,
            metaData: metaData
        )
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        
        try container.encode(from, forKey: .from)
        try container.encode(to, forKey: .to)
        try container.encode(metaData, forKey: .metaData)
        try container.encode(payload.toBase64String(), forKey: .payload)
    }
}

public extension MessageParticle {
    var textMessage: String? {
        guard let text = String(data: payload, encoding: .utf8) else {
            return nil
        }
        return text
    }
}
