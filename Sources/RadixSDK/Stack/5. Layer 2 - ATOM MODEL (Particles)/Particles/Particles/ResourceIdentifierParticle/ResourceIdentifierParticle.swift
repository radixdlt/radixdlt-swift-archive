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

/// A representation of something unique.
public struct ResourceIdentifierParticle:
    ParticleConvertible,
    RadixModelTypeStaticSpecifying,
    RadixCodable,
    Accountable
{
    // swiftlint:enable colon opening_brace

    public let resourceIdentifier: ResourceIdentifier
    
    /// This is in fact not really a `Nonce`, it is the only case where the value always should be zero.
    public let alwaysZeroNonce: Nonce = 0
    
    public init(
        resourceIdentifier: ResourceIdentifier
    ) {
        self.resourceIdentifier = resourceIdentifier
    }
    
}

// MARK: - From MutableSupplyTokenDefinitionParticle
public extension ResourceIdentifierParticle {
    init(token: TokenConvertible) {
        self.init(resourceIdentifier: token.tokenDefinitionReference)
    }
}

// MARK: - Decodable
public extension ResourceIdentifierParticle {
    enum CodingKeys: String, CodingKey {
        case serializer, version, destinations
        case resourceIdentifier = "rri"
        case alwaysZeroNonce = "nonce"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        resourceIdentifier = try container.decode(ResourceIdentifier.self, forKey: .resourceIdentifier)
    }
}

// MARK: - Encodable
public extension ResourceIdentifierParticle {
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .alwaysZeroNonce, value: alwaysZeroNonce),
            EncodableKeyValue(key: .resourceIdentifier, value: resourceIdentifier)
        ]
    }
}

// MARK: - Accountable
public extension ResourceIdentifierParticle {
    func addresses() throws -> Addresses {
        return try Addresses(addresses: [resourceIdentifier.address])
    }
}

// MARK: - RadixModelTypeStaticSpecifying
public extension ResourceIdentifierParticle {
    static let serializer: RadixModelType = .resourceIdentifierParticle
}
