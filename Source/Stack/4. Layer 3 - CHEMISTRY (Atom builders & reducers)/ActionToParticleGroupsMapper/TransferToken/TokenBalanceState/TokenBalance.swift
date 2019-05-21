//
//  TokenBalance.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public typealias ParticleHashId = EUID

public struct TokenBalance: Hashable, TokenDefinitionReferencing {
    public struct Consumables: DictionaryConvertible {
        public typealias Key = ParticleHashId
        public typealias Value = TransferrableTokensParticle
        public var dictionary: Map
        public init(dictionary: Map = [:]) {
            self.dictionary = dictionary
        }
    }
    public let amount: SignedAmount
    public let address: Address
    public let tokenDefinitionReference: ResourceIdentifier
    public let unconsumedTransferrable: Consumables
    
    public init(
        amount: SignedAmount,
        address: Address,
        tokenDefinitionReference: ResourceIdentifier,
        consumables: Consumables = [:]
    ) {
        self.amount = amount
        self.address = address
        self.tokenDefinitionReference = tokenDefinitionReference
        self.unconsumedTransferrable = consumables
    }
    
    public init(transferrable: TransferrableTokensParticle, spin: Spin) {
        self.init(
            amount: spin * transferrable.amount,
            address: transferrable.address,
            tokenDefinitionReference: transferrable.tokenDefinitionReference,
            consumables: [transferrable.hashId: transferrable]
        )
    }
    
    public init(spunTransferrable: SpunTransferrable) {
        self.init(transferrable: spunTransferrable.particle, spin: spunTransferrable.spin)
    }
}

public extension TokenBalance {
    
    enum Error: Swift.Error {
        case addressMismatch
        case tokenDefinitionReferenceMismatch
    }
    
    func merging(with other: TokenBalance) throws -> TokenBalance {
        guard other.address == address else {
            throw Error.addressMismatch
        }
        guard other.tokenDefinitionReference == tokenDefinitionReference else {
            throw Error.tokenDefinitionReferenceMismatch
        }
        
        let newAmount: SignedAmount = other.amount + amount
        let mergedConsumables = unconsumedTransferrable.merging(with: other.unconsumedTransferrable, uniquingKeysWith: { _, new in new })
        
        return TokenBalance(
            amount: newAmount,
            address: address,
            tokenDefinitionReference: tokenDefinitionReference,
            consumables: mergedConsumables
        )
    }
}

public extension TokenBalance {
    func hash(into hasher: inout Hasher) {
        hasher.combine(tokenDefinitionReference)
        hasher.combine(address)
    }
    
    static func == (lhs: TokenBalance, rhs: TokenBalance) -> Bool {
        return lhs.tokenDefinitionReference == rhs.tokenDefinitionReference && lhs.address == rhs.address
    }
}
