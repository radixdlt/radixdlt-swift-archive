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

public struct UnallocatedTokensParticle:
    ParticleConvertible,
    RadixCodable,
    RadixModelTypeStaticSpecifying,
    Accountable,
    CustomStringConvertible
{
    // swiftlint:enable colon opening_brace

    public static let serializer = RadixModelType.unallocatedTokensParticle
    
    public let tokenDefinitionReference: ResourceIdentifier
    public let granularity: Granularity
    public let nonce: Nonce
    public let amount: Supply
    public let permissions: TokenPermissions
    
    public init(
        amount: Supply,
        tokenDefinitionReference: ResourceIdentifier,
        permissions: TokenPermissions = .default,
        granularity: Granularity = .default,
        nonce: Nonce = Nonce()
    ) {
        
        self.granularity = granularity
        self.nonce = nonce
        self.amount = amount
        self.tokenDefinitionReference = tokenDefinitionReference
        self.permissions = permissions
    }
}

// MARK: CustomStringConvertible
public extension UnallocatedTokensParticle {
    var description: String {
        return """
        UnallocatedTokensParticle(
            amount: \(amount)
            rri: \(tokenDefinitionReference),
            permissions: \(permissions),
        
            (omitted: [`granularity`, `nonce`])
        )
        """
    }
}

// MARK: Decodable
public extension UnallocatedTokensParticle {
    
    enum CodingKeys: String, CodingKey {
        case serializer, version, destinations
        case tokenDefinitionReference
        case granularity, nonce, amount, permissions
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        let granularity = try container.decode(Granularity.self, forKey: .granularity)
        let nonce = try container.decode(Nonce.self, forKey: .nonce)
//        let positiveAmount = try container.decode(PositiveAmount.self, forKey: .amount)
//        let amount = try Supply(positiveAmount: positiveAmount)
        let amount = try container.decode(Supply.self, forKey: .amount)
        let permissions = try container.decode(TokenPermissions.self, forKey: .permissions)
        let tokenDefinitionReference = try container.decode(ResourceIdentifier.self, forKey: .tokenDefinitionReference)
        
        self.init(
            amount: amount,
            tokenDefinitionReference: tokenDefinitionReference,
            permissions: permissions,
            granularity: granularity,
            nonce: nonce
        )
    }
}

// MARK: RadixCodable
public extension UnallocatedTokensParticle {
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>] {
        return [
            EncodableKeyValue(key: .permissions, value: permissions),
            EncodableKeyValue(key: .granularity, value: granularity),
            EncodableKeyValue(key: .nonce, value: nonce),
            EncodableKeyValue(key: .tokenDefinitionReference, value: tokenDefinitionReference),
            EncodableKeyValue(key: .amount, value: amount)
        ]
    }
}

// MARK: - Accountable
public extension UnallocatedTokensParticle {
    func addresses() throws -> Addresses {
        return try Addresses(addresses: [tokenDefinitionReference.address])
    }
}

public extension UnallocatedTokensParticle {
    var debugPayloadDescription: String {
        return "\(amount)"
    }
}
