//
//  MessageParticle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon

/// A way of sending, receiving and storing data from a verified source via a Message Particle type. Message Particle instances may contain arbitrary byte data with arbitrary string-based key-value metadata.
///
/// Sending, storing and fetching data in some form is required for virtually every application - from everyday instant messaging to complex supply chain management.
/// A decentralised ledger needs to support simple and safe mechanisms for data management to be a viable platforms for decentralised applications (or DApps).
/// For a formal definition read [RIP - Messages][1].
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/412844083/RIP-3+Messages
///
public struct MessageParticle:
    ParticleConvertible,
    RadixModelTypeStaticSpecifying,
    Accountable,
    RadixCodable {
// swiftlint:enable colon
    
    public static let serializer = RadixModelType.messageParticle
    
    public let from: Address
    public let to: Address
    public let metaData: MetaData
    public let payload: Data
    public let nonce: Nonce
    
    public init(
        from: Address,
        to: Address,
        payload: Data,
        nonce: Nonce = Nonce(),
        metaData: MetaData = [:]
    ) {
        self.from = from
        self.to = to
        self.metaData = metaData
        self.payload = payload
        self.nonce = nonce
    }
}

// MARK: - Convenience init
public extension MessageParticle {
    init(from: Address, to: Address, message: String, nonce: Nonce = Nonce(), includeTimeNow: Bool = true) {
        
        let messageData = message.toData()
        let metaData: MetaData = includeTimeNow ? .timeNow : [:]
        
        self.init(
            from: from,
            to: to,
            payload: messageData,
            nonce: nonce,
            metaData: metaData
        )
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
    enum CodingKeys: String, CodingKey {
        case serializer

        case from
        case to
        case payload = "bytes"
        case nonce
        case metaData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let from = try container.decode(Address.self, forKey: .from)
        let to = try container.decode(Address.self, forKey: .to)
        let payloadBase64 = try container.decodeIfPresent(Base64String.self, forKey: .payload)
        let metaData = try container.decodeIfPresent(MetaData.self, forKey: .metaData) ?? [:]
        let nonce = try container.decode(Nonce.self, forKey: .nonce)
        
        self.init(
            from: from,
            to: to,
            payload: payloadBase64?.asData ?? Data(),
            nonce: nonce,
            metaData: metaData
        )
    }
    
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .from, value: from),
            EncodableKeyValue(key: .to, value: to),
            EncodableKeyValue(key: .payload, nonEmpty: payload, value: { $0.toBase64String() }),
            EncodableKeyValue(key: .nonce, value: nonce),
            EncodableKeyValue(key: .metaData, nonEmpty: metaData)
        ].compactMap { $0 }
    }
}

public extension MessageParticle {
    var textMessage: String {
        return String(data: payload)
    }
}
