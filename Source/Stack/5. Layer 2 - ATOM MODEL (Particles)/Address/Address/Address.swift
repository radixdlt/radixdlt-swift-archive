//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
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

// swiftlint:disable colon opening_brace

/// The public address of any Radix Public Key. From which we can derive the Public Key. Presented
/// as a Base58 string,
///
/// This is an example of a Radix address:
///
/// `JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor`
///
public struct Address:
    CBORDataConvertible,
    PrefixedJsonCodableByProxy,
    ExactLengthSpecifying,
    DataInitializable,
    StringRepresentable,
    AddressConvertible,
    PublicKeyOwner,
    Sharded,
    RadixHashable,
    DSONEncodable,
    Codable,
    Hashable,
    CustomStringConvertible
{

    // swiftlint:enable colon
    
    public static let length = 51
    
    /// `base58String` is the base58 encoding of `Z` where:
    ///
    /// `Z` = X | Y
    ///
    /// `|` = Concatenation between [Byte]
    ///
    /// `Y` = first 4 bytes of `H`
    ///
    /// `H` = RadixHash of X
    ///
    /// `X` = M | C
    ///
    /// `C` = Public Key on Compressed format (33 bytes)
    ///
    /// `M` = first byte of `Magic` number
    ///
    /// => Base58(Magic[0] | PKc | RadixHash(Magic[0] | PKc).prefix(4))
    public let base58String: Base58String
    public let publicKey: PublicKey
    
    public init(magic: Magic, publicKey: PublicKey) {
        self.publicKey = publicKey
        self.base58String = Address.checksummed(from: publicKey, magic: magic)
    }
    
    public init(base58String: Base58String) throws {
        try Address.validateLength(of: base58String)
        self.base58String = try Address.isChecksummed(base58String)
        let addressData = base58String.asData
        self.publicKey = try PublicKey(data: addressData[1...addressData.count - 5])
    }
}

// MARK: - Sharded
public extension Address {
    var shard: Shard {
        return publicKey.shard
    }
}

// MARK: - DataInitializable
public extension Address {
    init(data: Data) throws {
        try self.init(base58String: data.toBase58String())
    }
}

// MARK: - PrefixedJsonDecodableByProxy
public extension Address {
    typealias Proxy = Base58String
    var proxy: Proxy {
        return base58String
    }
    init(proxy: Proxy) throws {
        try self.init(base58String: proxy)
    }
}

// MARK: DSONPrefixSpecifying
public extension Address {
    var dsonPrefix: DSONPrefix {
        return .addressBase58
    }
}

// MARK: - DataConvertible
public extension Address {
    var asData: Data {
        return base58String.asData
    }
}

// MARK: - Convenience Init
public extension Address {
    init(publicKey: PublicKey, universeConfig: UniverseConfig) {
        self.init(magic: universeConfig.magic, publicKey: publicKey)
    }
}

// MARK: - StringInitializable
public extension Address {
    init(string: String) throws {
        let base58 = try Base58String(string: string)
        try self.init(base58String: base58)
    }
}

// MARK: - RadixHashable
public extension Address {
    var radixHash: RadixHash {
        return publicKey.radixHash
    }
}

// MARK: - StringRepresentable
public extension Address {
    var stringValue: String {
        return full
    }
}

// MARK: - CustomStringConvertible
public extension Address {
    
    var full: String {
        return base58String.stringValue
    }
    
    var description: String {
        return "<\(short)>"
    }
    
    var short: String {
        return [
            stringValue.prefix(4),
            "...",
            stringValue.suffix(4)
        ].joined()
    }
}

// MARK: - AddressConvertible
public extension Address {
    var address: Address {
        return self
    }
}

// MARK: - Checksum
public extension Address {
    
    static func checksummed(from dataConvertible: DataConvertible, magic: Magic) -> Base58String {
        let magicByte = magic.bytes[0]
        return checksummed(magicByte + dataConvertible.asData)
    }
    
    static func checksummed(_ dataConvertible: DataConvertible) -> Base58String {
        var data = dataConvertible.asData
        let checksum = RadixHash(unhashedData: data, hashedBy: Sha256TwiceHasher())
        data += checksum.prefix(Address.checksumByteCount)
        
        return data.toBase58String()
    }
    
    static func isChecksummed(base58: Base58String, magic: Magic) throws -> Base58String {
        let magicByte = magic.bytes[0]
        return try isChecksummed(magicByte + base58)
    }
    
    static let checksumByteCount = 4
    
    static func isChecksummed(_ dataConvertible: DataConvertible) throws -> Base58String {
        let data = dataConvertible.asData
        let checksumDropped = Data(data.dropLast(Address.checksumByteCount))
        let checksummedString = checksummed(checksumDropped)
        guard data == checksummedString.asData else {
            throw Error.checksumMismatch
        }
        return checksummedString
    }
    
    enum Error: Swift.Error, Equatable {
        case checksumMismatch
    }
}
