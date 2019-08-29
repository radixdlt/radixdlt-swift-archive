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

public struct TransferrableTokensParticle:
    ParticleConvertible,
    AddressConvertible,
    PublicKeyOwner,
    TokenDefinitionReferencing,
    Accountable,
    RadixCodable,
    RadixModelTypeStaticSpecifying,
    Throwing,
    CustomStringConvertible
{
    // swiftlint:enable colon opening_brace
    
    public static let serializer = RadixModelType.transferrableTokensParticle
    
    public let address: Address
    public let tokenDefinitionReference: ResourceIdentifier
    public let granularity: Granularity
    public let planck: Planck
    public let nonce: Nonce
    public let amount: PositiveAmount
    public let permissions: TokenPermissions?
    
    public init(
        amount: PositiveAmount,
        address: Address,
        tokenDefinitionReference: ResourceIdentifier,
        permissions: TokenPermissions? = .default,
        granularity: Granularity = .default,
        nonce: Nonce = Nonce(),
        planck: Planck = Planck()
    ) throws {
        
        guard amount.isExactMultipleOfGranularity(granularity) else {
            throw Error.amountNotMultipleOfGranularity(amount: amount, tokenGranularity: granularity)
        }
        
        self.address = address
        self.granularity = granularity
        self.nonce = nonce
        self.planck = planck
        self.amount = amount
        self.tokenDefinitionReference = tokenDefinitionReference
        self.permissions = permissions
    }
}

// MARK: Throwing
public extension TransferrableTokensParticle {
    enum Error: Swift.Error, Equatable {
        case amountNotMultipleOfGranularity(amount: PositiveAmount, tokenGranularity: Granularity)
    }
}

// MARK: Check permissions
public extension MutableSupplyTokenDefinitionParticle {
    func canBeMinted(by minter: Address) -> Bool {
        switch permissions.mintPermission {
        case .none: return false
        case .all: return true
        case .tokenOwnerOnly: return self.address == minter
        }
    }
    
    func canBeBurned(by burner: Address) -> Bool {
        switch permissions.burnPermission {
        case .none: return false
        case .all: return true
        case .tokenOwnerOnly: return self.address == burner
        }
    }
}

// MARK: Decodable
public extension TransferrableTokensParticle {
    
    enum CodingKeys: String, CodingKey {
        case serializer, version, destinations
        case tokenDefinitionReference
        case address, granularity, nonce, planck, amount, permissions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let address = try container.decode(Address.self, forKey: .address)
        let permissions = try container.decodeIfPresent(TokenPermissions.self, forKey: .permissions)
        
        let granularity = try container.decode(Granularity.self, forKey: .granularity)
        let nonce = try container.decode(Nonce.self, forKey: .nonce)
        let planck = try container.decode(Planck.self, forKey: .planck)
        let amount = try container.decode(PositiveAmount.self, forKey: .amount)
        let tokenDefinitionReference = try container.decode(ResourceIdentifier.self, forKey: .tokenDefinitionReference)
        
        try self.init(
            amount: amount,
            address: address,
            tokenDefinitionReference: tokenDefinitionReference,
            permissions: permissions,
            granularity: granularity,
            nonce: nonce,
            planck: planck
        )
    }
}

// MARK: RadixCodable
public extension TransferrableTokensParticle {
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .address, value: address),
            EncodableKeyValue(key: .amount, value: amount),
            EncodableKeyValue(key: .tokenDefinitionReference, value: tokenDefinitionReference),
            EncodableKeyValue(key: .permissions, ifPresent: permissions),
            EncodableKeyValue(key: .granularity, value: granularity),
            EncodableKeyValue(key: .nonce, value: nonce),
            EncodableKeyValue(key: .planck, value: planck)
        ].compactMap { $0 }
    }
}

// MARK: - CustomStringConvertible
public extension TransferrableTokensParticle {
    var description: String {
        
        let permissionString = permissions.ifPresent { ",\npermissions: \($0),\n" }
        
        return """
        TransferrableTokensParticle(
            address: \(address),
            rri: \(tokenDefinitionReference),
            amount: \(amount)\(permissionString)
        
            (omitted: [`planck, `granularity`, `nonce`])
        )
        """
    }
}

// MARK: - PublicKeyOwner
public extension TransferrableTokensParticle {
    var publicKey: PublicKey {
        return address.publicKey
    }
}

// MARK: Accountable
public extension TransferrableTokensParticle {
    func addresses() throws -> Addresses {
        return try Addresses(addresses: [address])
    }
}
