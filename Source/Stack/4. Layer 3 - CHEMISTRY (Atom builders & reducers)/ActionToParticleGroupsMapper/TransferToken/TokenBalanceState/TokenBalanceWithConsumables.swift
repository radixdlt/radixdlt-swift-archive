//
//  TokenBalance.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

//public extension TokenBalanceReferenceWithConsumables {
//
//    enum Error: Swift.Error {
//        case addressMismatch
//        case tokenDefinitionReferenceMismatch
//    }
//
//    func merging(with other: TokenBalanceReferenceWithConsumables) throws -> TokenBalanceReferenceWithConsumables {
//        guard other.address == address else {
//            throw Error.addressMismatch
//        }
//        guard other.tokenDefinitionReference == tokenDefinitionReference else {
//            throw Error.tokenDefinitionReferenceMismatch
//        }
//
//        let newAmount: SignedAmount = other.amount + amount
//        let mergedConsumables = unconsumedTransferrable.merging(with: other.unconsumedTransferrable, uniquingKeysWith: { _, new in new })
//
//        return TokenBalanceReferenceWithConsumables(
//            amount: newAmount,
//            address: address,
//            tokenDefinitionReference: tokenDefinitionReference,
//            consumables: mergedConsumables
//        )
//    }
//}
//
//public extension TokenBalanceReferenceWithConsumables {
//    func hash(into hasher: inout Hasher) {
//        hasher.combine(tokenDefinitionReference)
//        hasher.combine(address)
//    }
//
//    static func == (lhs: TokenBalanceReferenceWithConsumables, rhs: TokenBalanceReferenceWithConsumables) -> Bool {
//        return lhs.tokenDefinitionReference == rhs.tokenDefinitionReference && lhs.address == rhs.address
//    }
//}
