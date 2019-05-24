//
//  DefaultTransferTokenActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public struct DefaultTransferTokenActionToParticleGroupsMapper:
    TransferTokenActionToParticleGroupsMapper,
    Throwing
{
    // swiftlint:enable colon opening_brace
}

// MARK: - Throwing
public extension DefaultTransferTokenActionToParticleGroupsMapper {
    enum Error: Swift.Error, Equatable {
        case insufficientFunds
    }
}

public extension Array {
    static func += (array: inout Array, newElement: Element) {
        array.append(newElement)
    }
}

// MARK: - TransferTokenActionToParticleGroupsMapper
public extension DefaultTransferTokenActionToParticleGroupsMapper {
    
    func particleGroups(for transfer: Action, currentBalance tokenBalance: TokenBalance) throws -> ParticleGroups {
 
        guard
            let balance = try? PositiveAmount(signedAmount: tokenBalance.amount),
            balance >= transfer.amount
        else {
            throw Error.insufficientFunds
        }
      
        var (particleGroup, remainder) = transferToRecipientInParticleGroupWithRemainder(tokenBalance: tokenBalance, transfer: transfer)
        
        guard let tokensToRecipient = particleGroup.firstParticle(ofType: TransferrableTokensParticle.self, spin: .up) else {
            incorrectImplementation("Should have created a Transfer to the recipient")
        }
        
        // Remainder to sender
        if let remainder = remainder {
            let returnedToSender = TransferrableTokensParticle.returnToSender(
                of: transfer,
                amount: remainder,
                permissions: tokensToRecipient.permissions,
                granularity: tokensToRecipient.granularity
            ).withSpin(.up)
            
            particleGroup += returnedToSender
        }
        
        return ParticleGroups(groups: particleGroup)
    }
}

// MARK: - Private Helpers
private extension DefaultTransferTokenActionToParticleGroupsMapper {
    func transferToRecipientInParticleGroupWithRemainder(tokenBalance: TokenBalance, transfer: TransferTokenAction) -> (group: ParticleGroup, remainder: PositiveAmount?) {
        
        let tokenConsumables: [TransferrableTokensParticle] = tokenBalance.unconsumedTransferrable.values
            .filter { $0.tokenDefinitionReference == transfer.tokenResourceIdentifier }
        
        assert(!tokenConsumables.isEmpty, "No consumables, the implementation of `TokenBalance` is incorrect.")
        
        var consumerQuantity: PositiveAmount = 0
        let checkIfTransactionAmountIsCovered = { consumerQuantity >= transfer.amount }
        
        var consumedTokens = [AnySpunParticle]()
        
        for unspentToken in tokenConsumables where !checkIfTransactionAmountIsCovered() {
            consumerQuantity += unspentToken.amount
            consumedTokens += unspentToken.withSpin(.down)
        }
        
        assert(checkIfTransactionAmountIsCovered(), "The implementation of this function is incorrect, we should have asserted that we had balance enough earlier in this function")
        
        let permissions = tokenConsumables[0].permissions
        let granularity = tokenConsumables[0].granularity
        
        let toRecipient = TransferrableTokensParticle.toRecipient(in: transfer, permissions: permissions, granularity: granularity).withSpin(.up)
        
        let toRecipientParticleGroup = ParticleGroup(toRecipient + consumedTokens)
        
        let remainder = try? PositiveAmount(signedAmount: SignedAmount(amount: consumerQuantity) - SignedAmount(amount: transfer.amount))
        return (group: toRecipientParticleGroup, remainder: remainder)
    }
}

private extension TransferrableTokensParticle {
    static func toRecipient(
        in transfer: TransferTokenAction,
        permissions: TokenPermissions,
        granularity: Granularity
    ) -> TransferrableTokensParticle {
        
        return TransferrableTokensParticle(
            amount: transfer.amount,
            address: transfer.recipient,
            tokenDefinitionReference: transfer.tokenResourceIdentifier,
            permissions: permissions,
            granularity: granularity
        )
    }
    
    // https://www.youtube.com/watch?v=PU5xxh5UX4U
    static func returnToSender(
        of transfer: TransferTokenAction,
        amount: PositiveAmount,
        permissions: TokenPermissions,
        granularity: Granularity
    ) -> TransferrableTokensParticle {
        
        return TransferrableTokensParticle(
            amount: amount,
            address: transfer.sender,
            tokenDefinitionReference: transfer.tokenResourceIdentifier,
            permissions: permissions,
            granularity: granularity
        )
    }
}

extension Array {
    static func + (array: [Element], element: Element) -> [Element] {
        var mutable = array
        mutable.append(element)
        return mutable
    }
    
    static func + (element: Element, array: [Element]) -> [Element] {
        var mutable = [element]
        mutable.append(contentsOf: array)
        return mutable
    }
}
