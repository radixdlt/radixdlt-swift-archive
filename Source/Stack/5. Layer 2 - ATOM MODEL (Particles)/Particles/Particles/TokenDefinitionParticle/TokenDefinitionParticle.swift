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

/// For every new kind of Token, a Token Definition must be submitted that describes what the token is (e.g. its name) and how it should behave (e.g. only owner can mint tokens).
///
/// The specified properties - both general information about the Token and constraints on its use (e.g. only owner can mint tokens) are included in the Token Particle.
/// For the formal definition read [RIP - Tokens][1].
///
/// - seeAlso:
/// `TokenDefinitionParticle`
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/407241467/RIP-2+Tokens
///
public struct TokenDefinitionParticle:
    ParticleConvertible,
    RadixModelTypeStaticSpecifying,
    TokenConvertible,
    RadixCodable,
    RadixHashable,
    DSONEncodable,
    Hashable {
// swiftlint:enable colon
    
    public static let serializer = RadixModelType.tokenDefinitionParticle
    
    public let symbol: Symbol
    public let name: Name
    public let description: Description
    public let address: Address
    public let granularity: Granularity
    public let permissions: TokenPermissions
    public let iconUrl: URL?
    
    public init(
        symbol: Symbol,
        name: Name,
        description: Description,
        address: Address,
        granularity: Granularity = .default,
        permissions: TokenPermissions = .default,
        iconUrl: URL? = nil
    ) {
        self.symbol = symbol
        self.name = name
        self.description = description
        self.address = address
        self.granularity = granularity
        self.permissions = permissions
        self.iconUrl = iconUrl
    }
}

// MARK: - Hashable
public extension TokenDefinitionParticle {
    func hash(into hasher: inout Hasher) {
        hasher.combine(radixHash)
    }
}

// MARK: - From CreateTokenAction
public extension TokenDefinitionParticle {
    init(createTokenAction action: CreateTokenAction) {
        self.init(
            symbol: action.symbol,
            name: action.name,
            description: action.description,
            address: action.creator,
            granularity: action.granularity,
            permissions: action.tokenSupplyType.tokenPermissions,
            iconUrl: action.iconUrl
        )
    }
}

// MARK: - TokenDefinitionReferencing
public extension TokenDefinitionParticle {
    var tokenDefinitionReference: ResourceIdentifier {
        return ResourceIdentifier(address: address, symbol: symbol)
    }
}

// MARK: - TokenConvertible
public extension TokenDefinitionParticle {
    var tokenDefinedBy: Address {
        return address
    }
    
    var tokenSupplyType: SupplyType {
        return SupplyType(tokenPermissions: permissions)
    }
}
