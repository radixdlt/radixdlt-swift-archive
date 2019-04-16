//
//  RadixModelType.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum RadixModelType: String, Codable, CaseIterable {
    case atomEvent
    
    case signature
    case nodeInfo = "PEER"
    case radixSystem = "SYSTEM"
    case atom
    case particleGroup
    case spunParticle
    case udpNodeRunnerData = "UDPPEER"
    case universeConfig = "UNIVERSE"

    // MARK: - Particles
    case messageParticle
    case tokenDefinitionParticle
    case unallocatedTokensParticle
    case transferrableTokensParticle
    case uniqueParticle = "UNIQUEIDPARTICLE"
}

public extension RadixModelType {
    
    init(serializerId: Int) throws {
        guard let serializer = RadixModelType.precomputed.first(where: { $0.value == serializerId })?.key else {
            throw AtomModelDecodingError.unknownSerializer(got: serializerId)
        }
        
        self = serializer
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let serializerId = try container.decode(Int.self)
        try self.init(serializerId: serializerId)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(serializerId)
    }
    
    var serializerId: Int {
        guard let serializerId = RadixModelType.precomputed[self] else {
            incorrectImplementation("Check precomputed calculations")
        }
        return serializerId
    }
    
    private static var precomputed: [RadixModelType: Int] = {
        return [RadixModelType: Int](uniqueKeysWithValues: RadixModelType.allCases.map {
            ($0, JavaHash.from($0.rawValue.uppercased()))
        })
    }()
    
    static let jsonKey = "serializer"
}

extension RadixModelType: CBORConvertible {
    public func toCBOR() -> CBOR {
        return CBOR(integerLiteral: serializerId)
    }
}
