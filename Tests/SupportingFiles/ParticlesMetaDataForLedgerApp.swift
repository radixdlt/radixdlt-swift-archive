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
@testable import RadixSDK

func cborByteOffsetsOfUpParticlesIn(
    atom: Atom,
    atomCbor maybeAtomCbor: String? = nil
) throws -> [ParticleInAtomMetaData] {
    
    let atomCbor: String = maybeAtomCbor ?? atom.cborEncodedHexString()
    
    return atom.upParticles().enumerated().map { particleIndex, upParticle -> ParticleInAtomMetaData in
        
        func intervalByString(_ needle: String, in hayStack: String) -> ByteInterval? {
            guard let range: Range<String.Index> = hayStack.range(of: needle) else {
                return nil
            }
            let byteInterval = ByteInterval(
                stringIndex: hayStack.distance(
                    from: hayStack.startIndex,
                    to: range.lowerBound
                ),
                stringLength: needle.count
            )
            
          
            
            return byteInterval
        }
        
        let particleCborHexString = upParticle.someParticle.cborEncodedHexString()
        let particleIntervalInAtom = intervalByString(particleCborHexString, in: atomCbor)!
        let serializerValueCborHexString = upParticle.someParticle.particleType.serializer.serializerId.cborEncodedHexString()
        let serializerValueIntervalWithinParticle = intervalByString(serializerValueCborHexString, in: particleCborHexString)!
        
        let serializerIntervalWithinAtom = ByteInterval(
            startsAtByte: particleIntervalInAtom.startsAtByte + serializerValueIntervalWithinParticle.startsAtByte,
            byteCount: serializerValueIntervalWithinParticle.byteCount
        )
        
        guard let transferrableTokensParticle = upParticle.someParticle as? TransferrableTokensParticle else {
            return .otherParticle(particleItself: particleIntervalInAtom, serializer: serializerIntervalWithinAtom)
        }
        
        func intervalByKeyPath<Field>(_ keyPath: KeyPath<TransferrableTokensParticle, Field>) -> ByteInterval where Field: TTPFieldOfInterest & DSONEncodable {
            let fieldValue = transferrableTokensParticle[keyPath: keyPath]
            let fieldValueCbor = fieldValue.cborEncodedHexString()
            guard let intervalInTTP = intervalByString(fieldValueCbor, in: particleCborHexString) else {
                fatalError("Expected interval in TTP")
            }
            let adjusted = intervalInTTP + particleIntervalInAtom.startsAtByte
            return adjusted
            
        }
        
        return .transferrableParticle(
            particleItself: particleIntervalInAtom,
            address: intervalByKeyPath(\.address),
            amount: intervalByKeyPath(\.amount),
            serializer: serializerIntervalWithinAtom,
            tokenDefinitionReference: intervalByKeyPath(\.tokenDefinitionReference)
        )
    }
}

enum LedgerAppConstraints {
    
    static let maxTransfTokenParticleSpinUp = 6
    static let maxParticlesSpinUp = 15 // 240/16, where 16 is size of `ParticleInAtomMetaData` and 240 is LedgerMaxChunkSize-2-12, where 2 is number of bytes to encode AtomSize and 12 is number of bytes for BIP32 path
    
    static func validate(vector: LedgerSignAtomTestVector) -> Bool {
        guard vector.atomDescription.upParticles.transferrableTokensParticles <= maxTransfTokenParticleSpinUp else {
            print("Too many TransferrableTokensParticles with spin up")
            return false
        }
        
        guard vector.atomDescription.upParticles.totalCount <= maxParticlesSpinUp else {
            print("Too many particles with spin up in total.")
            return false
        }
        
        return true
    }
}

struct LedgerSignAtomTestVector: Equatable, Encodable {
    static let hardCodedPrivateKeyAlice = Expected.hardCodedPrivateKeyAlice
    
    struct Expected: Equatable, Encodable {
        static let hardCodedPrivateKeyAlice = "f423ae3097703022b86b87c15424367ce827d11676fae5c7fe768de52d9cce2e"
        let privateKeyAlice: String
        let publicKeyAlice: String
        let addressAlice: String
        let shaSha256HashOfAtomCborHex: String
        let signatureDEROfAtomHashHex: String
        let signatureRSOfAtomHashHex: String
        
        init(
            magic: Magic,
            atom: Atom
        ) {
            
            self.privateKeyAlice = Self.hardCodedPrivateKeyAlice
            let privateKeyAlice = try! PrivateKey(hex: Self.hardCodedPrivateKeyAlice)
            let publicKeyAlice = PublicKey(private: privateKeyAlice)
            self.publicKeyAlice = publicKeyAlice.compressedData.hex
            let addressAlice = Address(magic: magic, publicKey: publicKeyAlice)
            self.addressAlice = addressAlice.base58String.stringValue
            let atomHash = atom.radixHash
            self.shaSha256HashOfAtomCborHex = atomHash.asData.hex
            let signature = try! Signer.sign(hashedData: atomHash.asData, privateKey: privateKeyAlice)
            self.signatureRSOfAtomHashHex = signature.hex
            let signatureDER = try! signature.toDER()
            self.signatureDEROfAtomHashHex = signatureDER.hex
            
      
            assert(
                try! SignatureVerifier.verifyThat(
                    signature: signature,
                    signedMessage: .init(hash: atomHash),
                    usingKey: publicKeyAlice
                )
            )
        }
    }
    struct AtomDescription: Equatable, Encodable {
        let allAddresses: [String]
        let cborEncodedHex: String
        let particleSpinUpMetaDataHex: String
        
        let particleGroupCount: UInt
        let totalNumberOfParticles: UInt
        let upParticles: ParticleSpinCount
        let downParticles: ParticleSpinCount
        
        
        struct ParticleSpinCount: Equatable, Encodable {
            
            let transferrableTokensParticles: UInt
            let messageParticles: UInt
            let uniqueParticles: UInt
            let rriParticles: UInt
            let fixedSupplyTokenDefinitionParticles: UInt
            let mutableSupplyTokenDefinitionParticles: UInt
            let unallocatedTokensParticles: UInt
            
            let totalCount: UInt
            
            init(spin: Spin, atom: Atom) {
                var totalCount: UInt = 0
                func countParticles<P>(ofType particleType: P.Type) -> UInt where P: ParticleConvertible {
                    let counted = UInt(atom.particlesOfType(particleType, spin: spin).count)
                    totalCount += counted
                    return counted
                }
                self.transferrableTokensParticles = countParticles(ofType: TransferrableTokensParticle.self)
                self.messageParticles = countParticles(ofType: MessageParticle.self)
                self.uniqueParticles = countParticles(ofType: UniqueParticle.self)
                self.rriParticles = countParticles(ofType: ResourceIdentifierParticle.self)
                self.fixedSupplyTokenDefinitionParticles = countParticles(ofType: FixedSupplyTokenDefinitionParticle.self)
                self.mutableSupplyTokenDefinitionParticles = countParticles(ofType: MutableSupplyTokenDefinitionParticle.self)
                self.unallocatedTokensParticles = countParticles(ofType: UnallocatedTokensParticle.self)
                self.totalCount = totalCount
            }
        }
        
        init(atom: Atom, particleMetaData: [ParticleInAtomMetaData]) {
            let upParticles = ParticleSpinCount(spin: .up, atom: atom)
            self.upParticles = upParticles
            let downParticles = ParticleSpinCount(spin: .down, atom: atom)
            self.downParticles = downParticles
            self.cborEncodedHex = atom.cborEncodedHexString()
            self.allAddresses = try! atom.addresses().elements.map { $0.base58 }
            
            let totalNumberOfParticles = upParticles.totalCount + downParticles.totalCount
            self.totalNumberOfParticles = totalNumberOfParticles
            
            self.particleGroupCount = UInt(atom.particleGroups.count)
            
            
            let metaData: Data = particleMetaData.map {
                $0.toData()
            }.reduce(Data(), +)
            
            
            self.particleSpinUpMetaDataHex = metaData.hex
            
            
            assert(atom.upParticles().count == upParticles.totalCount)
            assert(atom.particles(spin: .down).count == downParticles.totalCount)
        }
    }
    


    
    let descriptionOfTest: String // e.g. "test of single transfer with short amount string"
    let bip32PathAlice = "44'/536'/2'/1/3"
    let universeMagic: Magic
    let atomDescription: AtomDescription
    let expected: Expected
    
//    let transfersHumanReadable: String
    
    
    let transfers: [TokensTransfer]?
    
    init(
        description: String,
        magic: Magic = 1,
        atom: Atom,
        actor: Address,
        transfers: [TokensTransfer]
    ) {
        self.descriptionOfTest = description
        self.universeMagic = magic
        let particleMetaData = try! cborByteOffsetsOfUpParticlesIn(atom: atom)
        self.atomDescription = AtomDescription(atom: atom, particleMetaData: particleMetaData)

        self.transfers = transfers.isEmpty ? nil : transfers
        self.expected = Expected(magic: magic, atom: atom)
        
    }
}

public struct TokensTransfer: Equatable, Encodable {
//    let recipient: Address
//    let amount: PositiveAmount
//    let tokenDefinitionReference: ResourceIdentifier
    let recipient: String
    let amount: String
    let tokenDefinitionReference: String
    let isChangeBackToUserHerself: Bool
    
    init(transferAction transfer: TransferTokensAction) {
        self.recipient = transfer.recipient.stringValue
        self.amount = transfer.amount.stringValue
        self.tokenDefinitionReference = transfer.tokenResourceIdentifier.stringValue
        self.isChangeBackToUserHerself = transfer.recipient == transfer.sender
    }
}


func += <I>(lhs: inout Optional<I>, rhs: I) where I: FixedWidthInteger {
    if lhs == nil {
        lhs = rhs
    } else {
        lhs! += rhs
    }
}

extension Magic {
    static func random() -> Self {
        let randomInt: Magic.Value = .random(in: 1...Magic.Value.max)
        return Self.init(integerLiteral: randomInt)
    }
}

public extension PublicKey {
    static func generateNew() -> Self {
        PublicKey(private: .init())
    }
}

private protocol TTPFieldOfInterest {
    static var nameOfFieldOfInterest: String { get }
}
extension TTPFieldOfInterest {
    static var nameOfFieldOfInterest: String {
        return "\(self)"
    }
}
extension Address: TTPFieldOfInterest {}
extension PositiveAmount: TTPFieldOfInterest {}
extension ResourceIdentifier: TTPFieldOfInterest {}

// "serializer"
extension String: TTPFieldOfInterest {}


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
        let contentBytes = Data(bytes.dropFirst())
        try self.init(data: contentBytes)
    }
    
}
extension UnsignedAmount: DSONDecodableFromByteString {}
extension ResourceIdentifier: DSONDecodableFromByteString {}
extension Address: DSONDecodableFromByteString {}
extension String: DSONDecodable {
    public init(cbor: SwiftCBOR.CBOR) throws {
        guard case .utf8String(let utf8String) = cbor else { throw DecodeCBORByteStringError.expectedByteString }
        self = utf8String
    }
}


func cborDecodeParticleMetaData(
    metaData particleInAtomMetaDatas: [ParticleInAtomMetaData],
    in atom: Atom,
    sender: Address
) throws -> String {
    
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
    
    var transferIndex = 0
    
    var descriptionOfAtom = ""
    
    let separator = "\n**************************\n"
//    var serializersOfNonTTPType = [String]()
    for metaData in particleInAtomMetaDatas {
        
        let _ = try decodeCbor(at: \.serializerByteInterval, from: metaData, into: String.self)
        
        if metaData.isTransferrableTokensParticle {
            let address = try decodeCbor(at: \.addressByteInterval!, from: metaData, into: Address.self)
            defer { transferIndex += 1 }
            guard address != sender else { continue }
            descriptionOfAtom += separator
            
            descriptionOfAtom += "Transfer at index: \(transferIndex)\n"
            
            descriptionOfAtom += "Address: \(address)\n"
            
            let amount = try decodeCbor(at: \.amountByteInterval!, from: metaData, into: PositiveAmount.self)
            descriptionOfAtom += "Amount: \(amount.magnitude)\n"
            
            let rri = try decodeCbor(at: \.tokenDefinitionReferenceByteInterval!, from: metaData, into: ResourceIdentifier.self)
            descriptionOfAtom += "Token: \(rri.name)\(separator)"
        }
//        else {
//            assert(metaData.isNonTransferrableTokensParticle)
//            let serializer = try decodeCbor(at: \.serializerByteInterval, from: metaData, into: String.self)
//            if !serializersOfNonTTPType.contains(serializer) {
//                serializersOfNonTTPType.append(serializer)
//            }
//        }
    }
    
//    if !serializersOfNonTTPType.isEmpty {
//        descriptionOfAtom += "\n======== NON TTP PARTICLES FOUND ===========\n["
//        descriptionOfAtom += serializersOfNonTTPType.joined(separator: ", ")
//        descriptionOfAtom += "]\n===========================================\n"
//    }
    
    return descriptionOfAtom
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

func + <I>(lhs: ByteInterval, rhs: I) -> ByteInterval where I: FixedWidthInteger {
    ByteInterval(startsAtByte: lhs.startsAtByte + UInt16(rhs), byteCount: lhs.byteCount)
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
    
    /// Byte interval of the particle itself, as in where the particle starts in some Atom, and the size of it.
    let particleItself: ByteInterval
    
    /// Byte interval of a value of field `address`, in a particle in some Atom.
    /// In the case of the Particle being TransferrableTokensParticle this
    /// will have non zero values, otherwise it will be (0, 0)
    let addressByteInterval: ByteInterval?
    
    /// Byte interval of a value of field `amount`, in a particle in some Atom.
    /// In the case of the Particle being TransferrableTokensParticle this
    /// will have non zero values, otherwise it will be (0, 0)
    let amountByteInterval: ByteInterval?
    
    /// Byte interval of a particles "serializer" value, identifying the type of particle, within some Atom
    let serializerByteInterval: ByteInterval
    
    /// Byte interval of a value of field `tokenDefinitionReference`, in a particle in some Atom.
    /// In the case of the Particle being TransferrableTokensParticle this
    /// will have non zero values, otherwise it will be (0, 0)
    let tokenDefinitionReferenceByteInterval: ByteInterval?
    
    private init(
        particleItself: ByteInterval,
        address: ByteInterval? = nil,
        amount: ByteInterval? = nil,
        serializer: ByteInterval,
        tokenDefinitionReference: ByteInterval? = nil
    ) {
        self.particleItself = particleItself
        self.addressByteInterval = address
        self.amountByteInterval = amount
        self.serializerByteInterval = serializer
        self.tokenDefinitionReferenceByteInterval = tokenDefinitionReference
    }
}

public extension ParticleInAtomMetaData {
    
    static func otherParticle(particleItself: ByteInterval, serializer: ByteInterval) -> Self {
        Self(
            particleItself: particleItself,
            serializer: serializer
        )
    }
    
    static func transferrableParticle(
        particleItself: ByteInterval,
        address: ByteInterval,
        amount: ByteInterval,
        serializer: ByteInterval,
        tokenDefinitionReference: ByteInterval
    ) -> Self {
        Self(
            particleItself: particleItself,
            address: address,
            amount: amount,
            serializer: serializer,
            tokenDefinitionReference: tokenDefinitionReference
        )
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
        // MUST be in the same order as the fields are encoded to CBOR:
        let fieldsInCorrectAlphabeticalOrder = [
            particleItself,
            addressByteInterval,
            amountByteInterval,
            serializerByteInterval,
            tokenDefinitionReferenceByteInterval
        ]
        
        let data = fieldsInCorrectAlphabeticalOrder.compactMap{ $0 ?? .zero }.map {
            $0.toData()
        }.reduce(Data(), +)
        
        assert(data.count == 20)
        
        return data
    }
}

public extension ParticleInAtomMetaData {
    
    
    var isTransferrableTokensParticle: Bool {
        [addressByteInterval, amountByteInterval, tokenDefinitionReferenceByteInterval].allSatisfy { $0 != nil }
    }
    
    var isNonTransferrableTokensParticle: Bool {
        [addressByteInterval, amountByteInterval, tokenDefinitionReferenceByteInterval].allSatisfy { $0 == nil }
    }
}
