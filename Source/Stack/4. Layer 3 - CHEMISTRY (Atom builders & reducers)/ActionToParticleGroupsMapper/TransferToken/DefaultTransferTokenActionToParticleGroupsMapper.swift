//
//  DefaultTransferTokensActionToParticleGroupsMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// swiftlint:disable colon opening_brace

public struct DefaultTransferTokensActionToParticleGroupsMapper:
    TransferTokensActionToParticleGroupsMapper,
    Throwing
{
    // swiftlint:enable colon opening_brace
}

// MARK: - TransferTokensActionToParticleGroupsMapper
public extension TransferTokensActionToParticleGroupsMapper {
    
    func particleGroups(for transfer: TransferTokenAction, upParticles: [ParticleConvertible]) throws -> ParticleGroups {
//    func particleGroups(for transfer: Action, currentBalance tokenBalance: TokenBalanceReferenceWithConsumables) throws -> ParticleGroups {
        let rri = transfer.tokenResourceIdentifier
        let upTransferrableParticles = upParticles.compactMap { $0 as? TransferrableTokensParticle }.filter { $0.tokenDefinitionReference == rri }
        
        let tokenBalanceOfSender = try TokenReferenceBalance(upTransferrableTokensParticles: upTransferrableParticles, tokenIdentifier: rri, owner: transfer.sender)
    
        guard
            tokenBalanceOfSender.amount >= transfer.amount
        else {
            throw TransferError.insufficientFunds
        }
      
        var (particleGroup, remainder) = transferToRecipientInParticleGroupWithRemainder(upTransferrableParticles: upTransferrableParticles, transfer: transfer)
        
        guard let tokensToRecipient = particleGroup.firstParticle(ofType: TransferrableTokensParticle.self, spin: .up) else {
            incorrectImplementation("Should have created a Transfer to the recipient")
        }
        
        // Remainder to sender
        if let remainder = remainder {
            let returnedToSender = TransferrableTokensParticle.returnToSender(
                transfer.sender,
                amount: remainder,
                permissions: tokensToRecipient.permissions,
                granularity: tokensToRecipient.granularity,
                resourceIdentifier: rri
            ).withSpin(.up)
            
            particleGroup += returnedToSender
        }
        
        return ParticleGroups(groups: particleGroup)
    }
}

public enum TransferError: Swift.Error, Equatable {
    case insufficientFunds
    case amountNotMultipleOfGranularity
}

// MARK: - Throwing
public extension DefaultTransferTokensActionToParticleGroupsMapper {
    typealias Error = TransferError
}

// MARK: - Private Helpers
private extension TransferTokensActionToParticleGroupsMapper {
    func transferToRecipientInParticleGroupWithRemainder(upTransferrableParticles tokenConsumables: [TransferrableTokensParticle], transfer: TransferTokenAction) -> (group: ParticleGroup, remainder: PositiveAmount?) {

        assert(!tokenConsumables.isEmpty, "No consumables")
        assert(!tokenConsumables.contains(where: { $0.tokenDefinitionReference != transfer.tokenResourceIdentifier }), "Consumables contains incompatible tokens")
        
        var consumerQuantity: NonNegativeAmount = 0
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
            amount: NonNegativeAmount(positive: transfer.amount),
            address: transfer.recipient,
            tokenDefinitionReference: transfer.tokenResourceIdentifier,
            permissions: permissions,
            granularity: granularity
        )
    }
    
    // https://www.youtube.com/watch?v=PU5xxh5UX4U
    // swiftlint:disable:next function_parameter_count
    static func returnToSender(
        _ sender: Address,
        amount: PositiveAmount,
        permissions: TokenPermissions,
        granularity: Granularity,
        resourceIdentifier: ResourceIdentifier
    ) -> TransferrableTokensParticle {
        
        return TransferrableTokensParticle(
            amount: NonNegativeAmount(positive: amount),
            address: sender,
            tokenDefinitionReference: resourceIdentifier,
            permissions: permissions,
            granularity: granularity
        )
    }
}

typealias ParticleHashId = HashId

//private struct TokenBalanceReferenceWithConsumables: TokenDefinitionReferencing {
//
//    let amount: SignedAmount
//    let address: Address
//    let tokenDefinitionReference: ResourceIdentifier
//    let unconsumedTransferrable: Consumables
//
//    init(transferrableParticlesWithSpinUp transferrableParticles: [TransferrableTokensParticle], matching transferAction: TransferTokenAction) throws {
//        self.unconsumedTransferrable = try Consumables(transferrableParticlesWithSpinUp: transferrableParticles, matching: transferAction)
//        self.tokenDefinitionReference = transferAction.tokenResourceIdentifier
//        self.address = transferAction.sender
//
//        let amounts: [PositiveAmount] = transferrableParticles.map({ $0.amount })
//        let sum: PositiveAmount = amounts.reduce(PositiveAmount.zero) { $0 + $1 }
//        self.amount = SignedAmount(amount: sum)
//    }
//}
//
//extension TokenBalanceReferenceWithConsumables {
//    struct Consumables: DictionaryConvertible, Throwing {
//        typealias Key = ParticleHashId
//        typealias Value = TransferrableTokensParticle
//        var dictionary: Map
//        init(dictionary: Map) {
//            fatalError()
//        }
//
//        fileprivate init(transferrableParticlesWithSpinUp transferrableParticles: [TransferrableTokensParticle], matching transferAction: TransferTokenAction) throws {
//            self.init()
//            for transferrableParticle in transferrableParticles {
//                guard transferrableParticle.tokenDefinitionReference == transferAction.tokenResourceIdentifier else {
//                    throw Error.resourceIdentifierMismatch(expected: transferAction.tokenResourceIdentifier, butGot: transferrableParticle.tokenDefinitionReference)
//                }
//                guard transferrableParticle.address == transferAction.sender else {
//                    throw Error.wrongOwner(expected: transferAction.sender, butGot: transferrableParticle.address)
//                }
//                dictionary[transferrableParticle.hashId] = transferrableParticle
//            }
//        }
//
//        enum Error: Swift.Error, Equatable {
//            case resourceIdentifierMismatch(expected: ResourceIdentifier, butGot: ResourceIdentifier)
//            case wrongOwner(expected: Address, butGot: Address)
//        }
//    }
//}
