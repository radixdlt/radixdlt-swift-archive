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

/// Defines a new kind of Token with mutable supply
public struct MutableSupplyTokenDefinitionParticle:
    ParticleConvertible,
    RadixModelTypeStaticSpecifying,
    TokenConvertible,
    RadixCodable,
    RadixHashable,
    DSONEncodable,
    Accountable,
    Throwing,
    Hashable {
// swiftlint:enable colon
    
    public static let serializer = RadixModelType.mutableSupplyTokenDefinitionParticle
    
    public let name: Name
    public let description: Description
    public let rri: ResourceIdentifier
    public let granularity: Granularity
    public let permissions: TokenPermissions
    public let iconUrl: URL?
    
    public init(
        symbol: Symbol,
        name: Name,
        description: Description,
        address: Address,
        granularity: Granularity = .default,
        permissions overridingPermissions: TokenPermissions?,
        iconUrl: URL? = nil
    ) throws {
        let permissions = overridingPermissions ?? TokenPermissions.mutableSupplyToken
        let mintPermission = permissions.mintPermission
        guard mintPermission == .all || mintPermission == .tokenOwnerOnly else {
            throw Error.someoneMustHavePermissionToMintToken(incorrectMintPermissionPassed: mintPermission)
        }
        
        self.name = name
        self.description = description
        self.rri = ResourceIdentifier(address: address, symbol: symbol)
        self.granularity = granularity
        self.permissions = permissions
        self.iconUrl = iconUrl
    }
}

// MARK: Throwing
public extension MutableSupplyTokenDefinitionParticle {
    enum Error: Swift.Error, Equatable {
        case someoneMustHavePermissionToMintToken(incorrectMintPermissionPassed: TokenPermission)
    }
}

// MARK: - Hashable
public extension MutableSupplyTokenDefinitionParticle {
    func hash(into hasher: inout Hasher) {
        hasher.combine(radixHash)
    }
}

// MARK: - Accountable
public extension MutableSupplyTokenDefinitionParticle {
    func addresses() throws -> Addresses {
        return try Addresses(addresses: [tokenDefinedBy])
    }
}

// MARK: - From CreateTokenAction
public extension MutableSupplyTokenDefinitionParticle {
    init(createTokenAction action: CreateTokenAction) throws {
        
        try self.init(
            symbol: action.symbol,
            name: action.name,
            description: action.description,
            address: action.creator,
            granularity: action.granularity,
            permissions: action.tokenPermissions,
            iconUrl: action.iconUrl
        )
    }
}

// MARK: - TokenDefinitionReferencing
public extension MutableSupplyTokenDefinitionParticle {
    var tokenDefinitionReference: ResourceIdentifier {
        return rri
    }
}

// MARK: - TokenConvertible
public extension MutableSupplyTokenDefinitionParticle {
    
    var symbol: Symbol {
        return Symbol(validated: tokenDefinitionReference.name)
    }
    
    var tokenDefinedBy: Address {
        return tokenDefinitionReference.address
    }
    
    var tokenSupplyType: SupplyType {
        return .mutable
    }
    
    var tokenPermissions: TokenPermissions? {
        return permissions
    }
}

public extension MutableSupplyTokenDefinitionParticle {
    var debugPayloadDescription: String {
        return String(describing: rri)
    }
}
