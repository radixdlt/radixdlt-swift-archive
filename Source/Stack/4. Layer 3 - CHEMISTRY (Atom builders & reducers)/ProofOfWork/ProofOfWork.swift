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
    private let magic: Magic
    public let nonce: Nonce
    public let targetNumberOfLeadingZeros: NumberOfLeadingZeros
    
    internal init(seed: Data, targetNumberOfLeadingZeros: NumberOfLeadingZeros, magic: Magic, nonce: Nonce) {
        self.seed = seed
        self.targetNumberOfLeadingZeros = targetNumberOfLeadingZeros
        self.magic = magic
        self.nonce = nonce
    }
}

// MARK: - Prove
public extension ProofOfWork {
    @discardableResult
    func prove() throws -> ProofOfWork {
        let hashed = hash()
        let numberOfLeadingZeros = hashed.numberOfLeadingZeroBits
        if numberOfLeadingZeros < targetNumberOfLeadingZeros {
            throw Error.tooFewLeadingZeros(
                expectedAtLeast: targetNumberOfLeadingZeros.numberOfLeadingZeros,
                butGot: UInt8(numberOfLeadingZeros)
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
            hashHex: \(hash().hex)
        """
    }
}

// MARK: - Error
public extension ProofOfWork {
    enum Error: Swift.Error {
        case workInputIncorrectLengthOfSeed(expectedByteCountOf: Int, butGot: Int)
        case tooFewLeadingZeros(expectedAtLeast: UInt8, butGot: UInt8)
    }
}

// MARK: - Private
private extension ProofOfWork {
    func hash() -> RadixHash {
        let unhashed: Data = magic.toFourBigEndianBytes() + seed + nonce.toEightBigEndianBytes()
        
        return RadixHash(unhashedData: unhashed)
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
