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

public extension ProofOfWork {
    var nonceAsString: String {
        return nonce.description
    }
    
    var description: String {
        return nonceAsString
    }
}

public extension ProofOfWork {
    
    static let expectedByteCountOfSeed = 32
    
    static func work(atom: Atom, magic: Magic, numberOfLeadingZeros: UInt8 = 16) throws -> ProofOfWork {
        
        return try work(seed: atom.radixHash.asData, magic: magic, numberOfLeadingZeros: numberOfLeadingZeros)
    }
    
    // swiftlint:disable:next function_body_length
    static func work(seed: Data, magic: Magic, numberOfLeadingZeros: UInt8 = 16) throws -> ProofOfWork {
        let numberOfLeadingZeros = Int(numberOfLeadingZeros)
        guard numberOfLeadingZeros > 0 else {
            throw Error.tooFewLeadingZeros(expectedAtLeast: 1, butGot: numberOfLeadingZeros)
        }
        let numberOfBits = expectedByteCountOfSeed * Int.bitsPerByte
        guard numberOfLeadingZeros <= numberOfBits else {
            throw Error.tooFewLeadingZeros(expectedAtLeast: 1, butGot: numberOfLeadingZeros)
        }
        guard seed.length == expectedByteCountOfSeed else {
            throw Error.workInputIncorrectLengthOfSeed(expectedByteCountOf: expectedByteCountOfSeed, butGot: seed.length)
        }
        var bitArray = BitArray(repeating: .one, count: numberOfBits)
        for index in 0..<numberOfLeadingZeros {
            bitArray[index] = .zero
        }
        let target = bitArray.asData
        let targetHex = target.hex
        var nonce: Nonce = 0
        let magic4Bytes = magicTo4BigEndianBytes(magic)
        let base: Data = magic4Bytes + seed
        var hex: String
        repeat {
            nonce += 1
            let unhashed = base + nonce.as8BytesBigEndian
            hex = RadixHash(unhashedData: unhashed).hex
        } while hex > targetHex
        return ProofOfWork(seed: seed, targetHex: target.toHexString(), magic: magic, nonce: nonce)
    }
    
    func prove() throws {
        let magic4Bytes = ProofOfWork.magicTo4BigEndianBytes(magic)
        let unhashed: Data = magic4Bytes + seed + nonce.as8BytesBigEndian
        let hashHex = RadixHash(unhashedData: unhashed).hex
        guard hashHex <= targetHex.hex else {
            throw Error.expected(hex: hashHex, toBeLessThanOrEqualToTargetHex: targetHex.hex)
        }
    }
    
    private static func magicTo4BigEndianBytes(_ magic: Magic) -> [Byte] {
        let magic4Bytes = CFSwapInt32HostToBig(UInt32(magic)).bytes
        assert(magic4Bytes.count == 4)
        return magic4Bytes
    }
    
    enum Error: Swift.Error {
        case tooFewLeadingZeros(expectedAtLeast: Int, butGot: Int)
        case tooManyLeadingZeros(expectedAtMost: Int, butGot: Int)
        case workInputIncorrectLengthOfSeed(expectedByteCountOf: Int, butGot: Int)
        case expected(hex: String, toBeLessThanOrEqualToTargetHex: String)
    }

}

private extension Nonce {
    var as8BytesBigEndian: [Byte] {
        let nonce8Bytes = CFSwapInt64HostToBig(UInt64(value)).bytes
        assert(nonce8Bytes.count == 8)
        return nonce8Bytes
    }
}

public extension Int {
    static var bitsPerByte = 8
}
