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

// swiftlint:disable colon

/// An ECC Public Key storing compressed key on binary format.
public struct PublicKey:
    PrefixedJsonCodableByProxy,
    CBORDataConvertible,
    DataInitializable,
    RadixHashable,
    DSONEncodable,
    PublicKeyOwner,
    Sharded,
    Hashable,
    CustomStringConvertible {
// swiftlint:enable colon
    
    public let compressedData: Data
    public init(data: Data) throws {
        self.compressedData = data
    }
}

// MARK: - PrefixedJsonCodableByProxy
public extension PublicKey {
    typealias Proxy = Base64String
    static let jsonPrefix = JSONPrefix.bytesBase64
    var proxy: Proxy {
        return toBase64String()
    }
    init(proxy: Proxy) throws {
        try self.init(base64: proxy)
    }
}

// MARK: - StringInitializable
public extension PublicKey {
    init(string: String) throws {
        let base64 = try Base64String(string: string)
        try self.init(base64: base64)
    }
}

// MARK: - DataConvertible
public extension PublicKey {
    var asData: Data { return compressedData }
}

// MARK: - AddressConvertible
public extension PublicKey {
    var publicKey: PublicKey {
        return self
    }
}

// MARK: - Sharded
public extension PublicKey {
    var shard: Shard {
        return hashEUID.shard
    }
}

// MARK: - CustomStringConvertible
public extension PublicKey {
    var description: String {
        return hex
    }
}

// MARK: - RadixHashable
public extension PublicKey {
    var radixHash: RadixHash {
        return RadixHash(unhashedData: compressedData)
    }
}

// MARK: - Equtable
public extension PublicKey {
    static func == (lhs: PublicKey, rhs: PublicKey) -> Bool {
        return lhs.compressedData == rhs.compressedData
    }
}

// MARK: - BitcoinKit
import BitcoinKit
public extension PublicKey {
    init(private privateKey: PrivateKey) {
        let bitcoinKitPrivateKey = privateKey.bitcoinKitPrivateKey
        let bitcoinKitPublicKey: BitcoinKit.PublicKey = bitcoinKitPrivateKey.publicKey()
        guard bitcoinKitPublicKey.isCompressed else {
            incorrectImplementation("Expected compressed public key")
        }
        do {
            try self.init(data: bitcoinKitPublicKey.data)
        } catch {
            incorrectImplementationShouldAlwaysBeAble(to: "Create a `PublicKey` from a `PrivateKey`", error)
        }
    }
}
