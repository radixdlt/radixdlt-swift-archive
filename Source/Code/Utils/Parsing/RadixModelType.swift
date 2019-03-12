//
//  RadixModelType.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import SwiftCBOR

public enum RadixModelType: Int, Codable {
    case signature = -434788200
    case nodeRunnerData = 2451810
    case radixSystem = -1833998801
    case atom = 2019665
    case particleGroup = -67058791
    case spunParticle = -993052100
    case udpNodeRunnerData = 151517315
    case universeConfig = 492321349

    // MARK: - Particles
    case messageParticle = -1254222995
    case tokenDefinitionParticle = -1034420571
    case burnedTokenParticle = 1180201038
    case mintedTokenParticle = 1745075425
    case transferredTokenParticle = 1311280198
    case uniqueParticle = 1446890290
}

public extension RadixModelType {
    var serializerId: Int {
        return rawValue
    }
    
    static let jsonKey = "serializer"
}

extension RadixModelType: CBORConvertible {
    // TODO: move into default conformance? in `extension CBORConvertible`
    public func encode() -> [UInt8] {
        return toCBOR().encode()
    }
    
    public func toCBOR() -> CBOR {
        return CBOR(integerLiteral: rawValue)
    }
}
