/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

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
    
    // swiftlint:disable:next function_body_length
    func particleGroups(for transfer: TransferTokenAction, upParticles: [AnyUpParticle]) throws -> ParticleGroups {
        let rri = transfer.tokenResourceIdentifier
        
        let upTransferrableParticles = upParticles.compactMap { try? UpParticle<TransferrableTokensParticle>(anyUpParticle: $0) }.filter { $0.particle.tokenDefinitionReference == rri }
        
        let tokenBalanceOfSender = try TokenReferenceBalance(upTransferrableTokensParticles: upTransferrableParticles, tokenIdentifier: rri, owner: transfer.sender)
        
        guard
            tokenBalanceOfSender.amount >= transfer.amount
        else {
            throw TransferError.insufficientFunds(
                currentBalance: tokenBalanceOfSender.amount,
                butTriedToTransfer: transfer.amount
            )
        }
        
        guard let tokenDefinitionParticle = upParticles.compactMap({ $0.particle as? TokenDefinitionParticle }).first(where: { $0.identifier == rri }) else {
            log.warning("Expected to found TokenDefinitionParticle with RRI: \(rri), amongst up particles: \(upParticles), but found none.")
            throw TransferError.foundNoTokenDefinition(forIdentifier: rri)
        }
        
        guard transfer.amount.isExactMultipleOfGranularity(tokenDefinitionParticle.granularity) else {
            throw TransferError.amountNotMultipleOfGranularity(amount: transfer.amount, tokenGranularity: tokenDefinitionParticle.granularity)
        }
        
        var (particles, remainder) = transferToRecipientInParticlesWithRemainder(upTransferrableParticles: upTransferrableParticles, transfer: transfer)

        guard let tokensToRecipient = particles.firstParticle(ofType: TransferrableTokensParticle.self, spin: .up) else {
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
            
            particles += returnedToSender
        }
        
        let metaData: MetaData
        if let attachment = transfer.attachment {
            metaData = [.attachment: Base64String(data: attachment).stringValue]
        } else { metaData = [:] }
        
        return [
            ParticleGroup(
                spunParticles: particles,
                metaData: metaData
            )
        ]
    }
}

public enum TransferError: Swift.Error, Equatable {
    case insufficientFunds(currentBalance: NonNegativeAmount, butTriedToTransfer: PositiveAmount)
    case foundNoTokenDefinition(forIdentifier: ResourceIdentifier)
    case amountNotMultipleOfGranularity(amount: PositiveAmount, tokenGranularity: Granularity)
}

// MARK: - Throwing
public extension DefaultTransferTokensActionToParticleGroupsMapper {
    typealias Error = TransferError
}

// MARK: - Private Helpers
private extension TransferTokensActionToParticleGroupsMapper {
    func transferToRecipientInParticlesWithRemainder(
        upTransferrableParticles: [UpParticle<TransferrableTokensParticle>],
        transfer: TransferTokenAction
    ) -> (particles: [AnySpunParticle], remainder: PositiveAmount?) {
        
        let tokenConsumables = upTransferrableParticles.map { $0.particle }

        assert(!tokenConsumables.isEmpty, "No consumables")
        assert(!tokenConsumables.contains(where: { $0.tokenDefinitionReference != transfer.tokenResourceIdentifier }), "Consumables contains incompatible tokens")
        
        var consumerQuantity: NonNegativeAmount = 0
        let isTransactionAmountCoveredYet = { consumerQuantity >= transfer.amount }
        
        var consumedTokens = [AnySpunParticle]()
        
        for unspentToken in tokenConsumables where !isTransactionAmountCoveredYet() {
            consumerQuantity += unspentToken.amount
            consumedTokens += unspentToken.withSpin(.down)
        }
        
        assert(isTransactionAmountCoveredYet(), "The implementation of this function is incorrect, we should have asserted that we had balance enough earlier in this function")
        
        let permissions = tokenConsumables[0].permissions
        let granularity = tokenConsumables[0].granularity
        
        let toRecipient = TransferrableTokensParticle.toRecipient(in: transfer, permissions: permissions, granularity: granularity).withSpin(.up)
        
        let toRecipientParticles = toRecipient + consumedTokens
        
        let remainder = try? PositiveAmount(signedAmount: SignedAmount(amount: consumerQuantity) - SignedAmount(amount: transfer.amount))
        
        return (particles: toRecipientParticles, remainder: remainder)
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

typealias ParticleHashId = HashEUID
