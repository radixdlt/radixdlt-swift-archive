//
//  File.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct ProofOfWork: CustomStringConvertible, CustomDebugStringConvertible {
    
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
    @discardableResult
    func prove() throws -> ProofOfWork {
        let hashed = hash()
        guard hashed.hex <= targetHex.hex else {
            throw Error.expected(
                hex: hashed.hex,
                toBeLessThanOrEqualToTargetHex: targetHex.hex
            )
        }
        return self
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

// MARK: CustomDebugStringConvertible
public extension ProofOfWork {
    var debugDescription: String {
        return """
            nonce: \(nonceAsString),
            targetHex: \(targetHex.hex)
            hashHex: \(hash().hex)
        """
    }
}

// MARK: - Error
public extension ProofOfWork {
    enum Error: Swift.Error {
        case workInputIncorrectLengthOfSeed(expectedByteCountOf: Int, butGot: Int)
        case expected(hex: String, toBeLessThanOrEqualToTargetHex: String)
    }
}

// MARK: - Private
private extension ProofOfWork {
    func hash() -> RadixHash {
        let unhashed: Data = magic.toFourBigEndianBytes() + seed + nonce.toEightBigEndianBytes()
        
        return RadixHash(unhashedData: unhashed)
    }
}

internal extension Magic {
    // MARK: - Endianess (Matching Java library ByteStream `putInt`)
    func toFourBigEndianBytes() -> [Byte] {
        let magic4Bytes = CFSwapInt32HostToBig(UInt32(value)).bytes
        assert(magic4Bytes.count == 4)
        return magic4Bytes
    }
}

// MARK: - Endianess (Matching Java library ByteStream `putLong`)
internal extension Nonce {
    func toEightBigEndianBytes() -> [Byte] {
        let nonce8Bytes = CFSwapInt64HostToBig(UInt64(value)).bytes
        assert(nonce8Bytes.count == 8)
        return nonce8Bytes
    }
}
