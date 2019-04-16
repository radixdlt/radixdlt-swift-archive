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
    
    private init(seed: Data, targetHex: HexString, magic: Magic, nonce: Nonce) {
        self.seed = seed
        self.targetHex = targetHex
        self.magic = magic
        self.nonce = nonce
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

public extension ProofOfWork {
    
    static let expectedByteCountOfSeed = 32
    
    static func work(seed: Data, magic: Magic, numberOfLeadingZeros: NumberOfLeadingZeros = .default) throws -> ProofOfWork {

        guard seed.length == expectedByteCountOfSeed else {
            throw Error.workInputIncorrectLengthOfSeed(expectedByteCountOf: expectedByteCountOfSeed, butGot: seed.length)
        }
        
        let numberOfBits = expectedByteCountOfSeed * Int.bitsPerByte
        var bitArray = BitArray(repeating: .one, count: numberOfBits)
        
        for index in 0..<Int(numberOfLeadingZeros.numberOfLeadingZeros) {
            bitArray[index] = .zero
        }
        
        let target = bitArray.asData
        let targetHex = bitArray.hex
        var nonce: Nonce = 0
        let base: Data = magicTo4BigEndianBytes(magic) + seed
        var hex: String
        repeat {
            nonce += 1
            let unhashed = base + nonce.as8BytesBigEndian
            hex = RadixHash(unhashedData: unhashed).hex
        } while hex > targetHex
        
        return ProofOfWork(seed: seed, targetHex: target.toHexString(), magic: magic, nonce: nonce)
    }
    
    func prove() throws {
        let unhashed: Data = ProofOfWork.magicTo4BigEndianBytes(magic) + seed + nonce.as8BytesBigEndian
        let hashHex = RadixHash(unhashedData: unhashed).hex
        guard hashHex <= targetHex.hex else {
            throw Error.expected(hex: hashHex, toBeLessThanOrEqualToTargetHex: targetHex.hex)
        }
    }
}

// MARK: - Error
public extension ProofOfWork {
    enum Error: Swift.Error {
        case workInputIncorrectLengthOfSeed(expectedByteCountOf: Int, butGot: Int)
        case expected(hex: String, toBeLessThanOrEqualToTargetHex: String)
    }
}

// MARK: - Convenience
public extension ProofOfWork {
    static func work(atom: Atom, magic: Magic, numberOfLeadingZeros: NumberOfLeadingZeros = .default) throws -> ProofOfWork {
        return try work(seed: atom.radixHash.asData, magic: magic, numberOfLeadingZeros: numberOfLeadingZeros)
    }
}

// MARK: - Endianess (Matching Java library ByteStream `putInt`)
private extension ProofOfWork {
    static func magicTo4BigEndianBytes(_ magic: Magic) -> [Byte] {
        let magic4Bytes = CFSwapInt32HostToBig(UInt32(magic)).bytes
        assert(magic4Bytes.count == 4)
        return magic4Bytes
    }
}

// MARK: - Endianess (Matching Java library ByteStream `putLong`)
private extension Nonce {
    var as8BytesBigEndian: [Byte] {
        let nonce8Bytes = CFSwapInt64HostToBig(UInt64(value)).bytes
        assert(nonce8Bytes.count == 8)
        return nonce8Bytes
    }
}

