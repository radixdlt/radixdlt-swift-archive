//
// MIT License
//
// Copyright (c) 2018-2020 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import XCTest
@testable import RadixSDK

final class TransferrableTokensParticleTests: TestCase {

    func testIndexingParticlesWithinCborEncode() throws {
        let alice = Address(privateKey: 1)
        let bob = Address(privateKey: 2)
        let clara = Address(privateKey: 3)
        let diana = Address(privateKey: 4)
        let hal9000 = Address(privateKey: 5)
        
        let (genesisAtom, rri) = try { () -> (Atom, ResourceIdentifier) in
            
            let createTokenAction: CreateTokenAction = try .new(
                creator: alice,
                symbol: "ZELDA",
                supply: .fixed(to: 1000)
            )

            let mapper = IndependentTransactionToAtomMapper()

            let createTokenAtom = try mapper.atomFrom(
                transaction: .init(actions: [
                    createTokenAction
                ]),
                addressOfActiveAccount: alice
            )
            
            return (createTokenAtom, createTokenAction.tokenDefinitionReference)
        }()

        let atomStore = InMemoryAtomStore(genesisAtoms: [genesisAtom])
        XCTAssertEqual(atomStore.upParticles(at: alice).count, 2)
        let transactionToAtomMapper = DefaultTransactionToAtomMapper(atomStore: atomStore)
        
        let manyFromAlice = Transaction(TokenContext(rri: rri, actor: alice)) {
            Transfer(amount: 1, to: bob)
            Transfer(amount: 2, to: clara)
            Transfer(amount: 3, to: diana)
            Message(text: "Open the pod bay doors", to: hal9000)
        }
        
        let atom = try transactionToAtomMapper.atomFrom(
            transaction: manyFromAlice,
            addressOfActiveAccount: alice
        )
        
//        let jsonEncoder = RadixJSONEncoder(outputFormat: [.prettyPrinted, .sortedKeys])
//        let jsonData = try! jsonEncoder.encode(atom)
//        print(jsonData.toString())
//        print(atom.cborEncodedHexString())
        
        XCTAssertEqual(atom.upParticles().count, 8) // 'change' (money) back to Alice => many particles
 
        let offsets = try cborByteOffsetsOfUpParticlesIn(atom: atom)
        XCTAssertEqual(offsets.count, 8)
        
        let metaData: Data = offsets.map {
            $0.toData()
        }.reduce(Data(), +)

        XCTAssertEqual(metaData.hex, "01dd015902160023015b003d005300290370015900d20023015b003d0379002906cd015907060023015b003d005300290860015908990023015b003d086900290d5001590d890023015b003d005300290ee3015900d20023015b003d0eec00291076015908990023015b003d0eec002912400107000000000000000000000000")
        
        cborDecodeParticleMetaData(metaData: offsets, in: atom)
    }
}

private protocol TTPFieldOfInterest {}
extension Address: TTPFieldOfInterest {}
extension PositiveAmount: TTPFieldOfInterest {}
extension ResourceIdentifier: TTPFieldOfInterest {}


import SwiftCBOR
public protocol DSONDecodable {
    init(cbor: SwiftCBOR.CBOR) throws
}
public extension DSONDecodable {
    
    init(unknownCborRawBytes: [Byte]) throws {
        guard let cbor = try? CBOR.decode(unknownCborRawBytes) else {
            throw DecodeCBORError.noCborInData
        }
        try self.init(cbor: cbor)
    }
    
    init(unknownCborRawData: Data) throws {
        try self.init(unknownCborRawBytes: unknownCborRawData.bytes)
    }
}

public protocol DSONDecodableFromByteString: DSONDecodable {
    init(byteString: [Byte]) throws
}
enum DecodeCBORError: Swift.Error {
    case noCborInData
}
enum DecodeCBORByteStringError: Swift.Error {
    case expectedByteString
    case noBytes
    case incorrectByteStringPrefix(got: Byte, butExpected: Byte)
}

extension DSONDecodable where Self: DSONDecodableFromByteString {
    public init(cbor: SwiftCBOR.CBOR) throws {
        guard case .byteString(let byteString) = cbor else { throw DecodeCBORByteStringError.expectedByteString }
        try self.init(byteString: byteString)
    }
}
extension DSONDecodableFromByteString where Self: DataInitializable, Self: DSONPrefixedDataConvertible {
    public init(byteString bytes: [Byte]) throws {
        guard let firstByte = bytes.first else {
            throw DecodeCBORByteStringError.noBytes
        }
        let expectedDSONByte = Self.dsonPrefix.byte
        guard firstByte == expectedDSONByte else {
            throw DecodeCBORByteStringError.incorrectByteStringPrefix(
                got: firstByte,
                butExpected: expectedDSONByte
            )
        }
        try self.init(data: Data(bytes.dropFirst()))
    }
    
}
extension UnsignedAmount: DSONDecodableFromByteString {}
extension ResourceIdentifier: DSONDecodableFromByteString {}
extension Address: DSONDecodableFromByteString {}


private extension TransferrableTokensParticleTests {
    
    func cborDecodeParticleMetaData(metaData particleInAtomMetaDatas: [ParticleInAtomMetaData], in atom: Atom) {
        let atomCbor = try! atom.toDSON(output: .hash)
        func extractCborBytesFromAtom(byteInterval: ByteInterval) -> Data {
            let slice: Data.SubSequence = atomCbor[byteInterval.startsAtByte...byteInterval.endsWithByte]
            return Data(slice)
        }
        
        func decodeCbor<T>(
            at intervalKeyPath: KeyPath<ParticleInAtomMetaData, ByteInterval>,
            from metaData: ParticleInAtomMetaData,
            into type: T.Type
        ) throws -> T where T: TTPFieldOfInterest & DSONDecodable {
            let byteInterval = metaData[keyPath: intervalKeyPath]
            let cborBytesOfField = extractCborBytesFromAtom(byteInterval: byteInterval)
            return try T(unknownCborRawData: cborBytesOfField)
        }
        
        for metaData in particleInAtomMetaDatas {
            let particleInterval = metaData.intervalOfParticleInAtom
            let particleCbor = extractCborBytesFromAtom(byteInterval: particleInterval)

            XCTAssertLessThanOrEqual(
                abs(particleCbor.count - Int(particleInterval.byteCount)),
                1
            )
            
            if metaData.isTransferrableTokensParticle {
                
                XCTAssertNoThrow(
                    try decodeCbor(at: \.intervalOfRRI, from: metaData, into: ResourceIdentifier.self)
                )
                
                XCTAssertNoThrow(
                    try decodeCbor(at: \.intervalOfAmount, from: metaData, into: PositiveAmount.self)
                )
                
                XCTAssertNoThrow(
                    try decodeCbor(at: \.intervalOfRecipientAddress, from: metaData, into: Address.self)
                )
                
            } else {
                assert(metaData.isNonTransferrableTokensParticle)
            }
        }
    }
    
    func cborByteOffsetsOfUpParticlesIn(atom: Atom) throws -> [ParticleInAtomMetaData] {
        let atomCbor = atom.cborEncodedHexString()
        
        return atom.upParticles().enumerated().map { particleIndex, upParticle -> ParticleInAtomMetaData in

            func intervalByString(_ string: String) -> ByteInterval? {
                guard let range: Range<String.Index> = atomCbor.range(of: string) else {
                    return nil
                }
                return ByteInterval(
                    stringIndex: atomCbor.distance(
                        from: atomCbor.startIndex,
                        to: range.lowerBound
                    ),
                    stringLength: string.count
                )
            }


            let inAtom = intervalByString(upParticle.someParticle.cborEncodedHexString())!

            guard let transferrableTokensParticle = upParticle.someParticle as? TransferrableTokensParticle else {
                return .otherParticle(inAtom: inAtom)
            }

            func intervalByKeyPath<Field>(_ keyPath: KeyPath<TransferrableTokensParticle, Field>) -> ByteInterval where Field: TTPFieldOfInterest & DSONEncodable {
                let fieldValue = transferrableTokensParticle[keyPath: keyPath]
                let fieldValueCbor = fieldValue.cborEncodedHexString()
                guard let intervalInTTP = intervalByString(fieldValueCbor) else {
                    fatalError("Expected interval in TTP")
                }
                return intervalInTTP
            }

            return .transferrableParticle(
                inAtom: inAtom,
                amount: intervalByKeyPath(\.amount),
                rri: intervalByKeyPath(\.tokenDefinitionReference),
                recipient: intervalByKeyPath(\.address)
            )
        }
    }
    
}

    
    
// Four bytes
public struct ByteInterval {
    let startsAtByte: UInt16
    let byteCount: UInt16
    
    init(
        startsAtByte: UInt16,
        byteCount: UInt16
    ) {
        self.startsAtByte = startsAtByte
        self.byteCount = byteCount
    }
}

public extension ByteInterval {
    var endsWithByte: UInt16 {
        startsAtByte + byteCount
    }
}

public extension ByteInterval {
    init(stringIndex: Int, stringLength: Int) {
        let toUint: (Int) -> (UInt16) = { .init($0)/2 }

        self.init(
            startsAtByte: toUint(stringIndex),
            byteCount: toUint(stringLength)
        )
    }
}
public extension ByteInterval {
    static let zero = Self(startsAtByte: 0, byteCount: 0)
}

/// 16 bytes, in case of pointer to other particle than `TransferrableTokensParticle`, the last 12 bytes will be all `0`
/// used by Ledger app to distinguish between `ParticleInAtomMetaData` for `TransferrableTokensParticle` and ALL other
/// particles types
public struct ParticleInAtomMetaData {
    /// Byte interval of a Particle in an Atom
    let intervalOfParticleInAtom: ByteInterval
    
    /// Byte interval of a value of field `amount`, in a particle in some Atom.
    ///
    /// In the case of the Particle being TransferrableTokensParticle this
    /// will have non zero values, otherwise it will be (0, 0)
    let intervalOfAmount: ByteInterval
    
    /// Byte interval of a value of field `tokenDefinitionReference`, in a particle in some Atom.
    ///
    /// In the case of the Particle being TransferrableTokensParticle this
    /// will have non zero values, otherwise it will be (0, 0)
    let intervalOfRRI: ByteInterval
    
    /// Byte interval of a value of field `address`, in a particle in some Atom.
    ///
    /// In the case of the Particle being TransferrableTokensParticle this
    /// will have non zero values, otherwise it will be (0, 0)
    let intervalOfRecipientAddress: ByteInterval
    
    private init(
        inAtom: ByteInterval,
        amount: ByteInterval,
        rri: ByteInterval,
        recipient: ByteInterval
    ) {
        self.intervalOfParticleInAtom = inAtom
        self.intervalOfAmount           = amount
        self.intervalOfRRI              = rri
        self.intervalOfRecipientAddress = recipient
    }
}

public extension ParticleInAtomMetaData {
    
    static func otherParticle(inAtom: ByteInterval) -> Self {
        return Self(inAtom: inAtom, amount: .zero, rri: .zero, recipient: .zero)
    }
    
    static func transferrableParticle(
        inAtom: ByteInterval,
        amount: ByteInterval,
        rri: ByteInterval,
        recipient: ByteInterval
    ) -> Self {
        return Self(inAtom: inAtom, amount: amount, rri: rri, recipient: recipient)
    }
}

public extension ByteInterval {
    func toData() -> Data {
        [startsAtByte, byteCount].map {
            CFSwapInt16HostToBig($0).asData
        }.reduce(Data(), +)
    }
}

public extension ParticleInAtomMetaData {
    func toData() -> Data {
        [intervalOfParticleInAtom, intervalOfAmount, intervalOfRRI, intervalOfRecipientAddress].map {
            $0.toData()
        }.reduce(Data(), +)
    }
}

public extension ParticleInAtomMetaData {


    var isTransferrableTokensParticle: Bool {
        [intervalOfAmount, intervalOfRRI, intervalOfRecipientAddress].allSatisfy {
            switch ($0.byteCount > 0, $0.startsAtByte > 0) {
            case (true, true): return true
            case (false, false): return false
            default:
                fatalError("Bad state: startsAt: \($0.startsAtByte), byteCount: \($0.byteCount)")
            }
        }
    }

    var isNonTransferrableTokensParticle: Bool {
        [intervalOfAmount, intervalOfRRI, intervalOfRecipientAddress].allSatisfy {
            switch ($0.byteCount == 0, $0.startsAtByte == 0) {
            case (true, true): return true
            case (false, false): return false
            default:
                fatalError("Bad state: startsAt: \($0.startsAtByte), byteCount: \($0.byteCount)")
            }
        }
    }
}
