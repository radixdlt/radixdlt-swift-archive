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

/// Defines a new kind of Token with fixed supply
public struct FixedSupplyTokenDefinitionParticle:
    ParticleConvertible,
    RadixModelTypeStaticSpecifying,
    TokenConvertible,
    RadixCodable,
    RadixHashable,
    DSONEncodable,
    Accountable,
    Hashable {
// swiftlint:enable colon
    
    public static let serializer = RadixModelType.fixedSupplyTokenDefinitionParticle
    
    public let name: Name
    public let description: Description
    public let rri: ResourceIdentifier
    public let granularity: Granularity
    public let fixedTokenSupply: PositiveAmount
    public let iconUrl: URL?
    
    public init(
        symbol: Symbol,
        name: Name,
        description: Description,
        address: Address,
        supply: PositiveSupply,
        granularity: Granularity = .default,
        iconUrl: URL? = nil
    ) {
        self.name = name
        self.description = description
        self.rri = ResourceIdentifier(address: address, symbol: symbol)
        self.granularity = granularity
        self.iconUrl = iconUrl
        self.fixedTokenSupply = PositiveAmount(other: supply)
    }
}

// MARK: - Hashable
public extension FixedSupplyTokenDefinitionParticle {
    func hash(into hasher: inout Hasher) {
        hasher.combine(radixHash)
    }
}

// MARK: - Accountable
public extension FixedSupplyTokenDefinitionParticle {
    func addresses() throws -> Addresses {
        return try Addresses(addresses: [tokenDefinedBy])
    }
}

// MARK: - From CreateTokenAction
public extension FixedSupplyTokenDefinitionParticle {
    init(createTokenAction action: CreateTokenAction, positiveSupply: PositiveSupply) {

        self.init(
            symbol: action.symbol,
            name: action.name,
            description: action.description,
            address: action.creator,
            supply: positiveSupply,
            granularity: action.granularity,
            iconUrl: action.iconUrl
        )
    }
}

// MARK: - TokenDefinitionReferencing
public extension FixedSupplyTokenDefinitionParticle {
    var tokenDefinitionReference: ResourceIdentifier {
        return rri
    }
}

// MARK: - TokenConvertible
public extension FixedSupplyTokenDefinitionParticle {
    
    var symbol: Symbol {
        return Symbol(validated: tokenDefinitionReference.name)
    }
    
    var tokenDefinedBy: Address {
        return tokenDefinitionReference.address
    }
    
    var tokenSupplyType: SupplyType {
        return .fixed
    }
    
    var tokenPermissions: TokenPermissions? { nil }
    
    var supply: Supply? { Supply(subset: fixedTokenSupply) }
}

public extension FixedSupplyTokenDefinitionParticle {
    var debugPayloadDescription: String {
        return """
        fixed(\(fixedTokenSupply)), \(self.tokenDefinitionReference)"
        """
    }
}
