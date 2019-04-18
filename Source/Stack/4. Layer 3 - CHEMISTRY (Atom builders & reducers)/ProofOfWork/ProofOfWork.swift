//
//  File.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct ProofOfWork: CustomStringConvertible {
    
    private let seed: Data
    private let targetHex: HexString
    private let magic: Magic
    private let nonce: Nonce
    
    internal init(seed: Data, targetHex: HexString, magic: Magic, nonce: Nonce) {
        self.seed = seed
        self.targetHex = targetHex
        self.magic = magic
        self.nonce = nonce
    }
}

// MARK: - Prove
public extension ProofOfWork {
    func prove() throws {
        let unhashed: Data = magic.magicTo4BigEndianBytes + seed + nonce.as8BytesBigEndian
        let hashHex = RadixHash(unhashedData: unhashed).hex
        guard hashHex <= targetHex.hex else {
            throw Error.expected(hex: hashHex, toBeLessThanOrEqualToTargetHex: targetHex.hex)
        }
    }
}

// MARK: - Public
public extension ProofOfWork {
    var nonceAsString: String {
        return nonce.description
    }
}

// MARK: CustomStringConvertible
public extension ProofOfWork {
    var description: String {
        return nonceAsString
    }
}

// MARK: - Error
public extension ProofOfWork {
    enum Error: Swift.Error {
        case workInputIncorrectLengthOfSeed(expectedByteCountOf: Int, butGot: Int)
        case expected(hex: String, toBeLessThanOrEqualToTargetHex: String)
    }
}

internal extension Magic {
    // MARK: - Endianess (Matching Java library ByteStream `putInt`)
    var magicTo4BigEndianBytes: [Byte] {
        let magic4Bytes = CFSwapInt32HostToBig(UInt32(self)).bytes
        assert(magic4Bytes.count == 4)
        return magic4Bytes
    }
}

// MARK: - Endianess (Matching Java library ByteStream `putLong`)
internal extension Nonce {
    var as8BytesBigEndian: [Byte] {
        let nonce8Bytes = CFSwapInt64HostToBig(UInt64(value)).bytes
        assert(nonce8Bytes.count == 8)
        return nonce8Bytes
    }
}
