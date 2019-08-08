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

public struct DefaultTransferTokensActionToParticleGroupsMapper:
    TransferTokensActionToParticleGroupsMapper,
    Throwing
{
    // swiftlint:enable colon opening_brace
}

// MARK: - TransferTokensActionToParticleGroupsMapper
public extension TransferTokensActionToParticleGroupsMapper {
    
    func particleGroups(for transfer: TransferTokenAction, upParticles: [AnyUpParticle]) throws -> ParticleGroups {
        
        try validateInput(transfer: transfer, upParticles: upParticles)
        
        let transitioner = FungibleParticleTransitioner<TransferrableTokensParticle, TransferrableTokensParticle>(
            transitioner: { try TransferrableTokensParticle(transferrableTokensParticle: $0, amount: $1, address: transfer.recipient) },
            transitionAndMigrateCombiner: TransferrableTokensParticle.reducing(particles:),
            migrator: TransferrableTokensParticle.init(transferrableTokensParticle:amount:),
            amountMapper: { $0.amount.asNonNegative }
        )
        
        let particles = try transitioner.particlesFrom(transfer: transfer, upParticles: upParticles)
    
        return [
            ParticleGroup(
                spunParticles: particles,
                metaData: transfer.metaDataFromAttachmentOrEmpty
            )
        ]
    }
}

private extension TransferTokensActionToParticleGroupsMapper {
    func validateInput(transfer: TransferTokenAction, upParticles: [AnyUpParticle]) throws {
        let rri = transfer.tokenResourceIdentifier
        
        let tokenDefinition: TokenConvertible
        if let mutableSupplyTokenDefinitionParticle = upParticles.compactMap({ $0.particle as? MutableSupplyTokenDefinitionParticle }).first(where: { $0.tokenDefinitionReference == rri }) {
            tokenDefinition = mutableSupplyTokenDefinitionParticle
        } else if let fixedSupplyTokenDefinitionsParticle =  upParticles.compactMap({ $0.particle as? FixedSupplyTokenDefinitionParticle }).first(where: { $0.tokenDefinitionReference == rri }) {
            tokenDefinition = fixedSupplyTokenDefinitionsParticle
        } else {
            log.warning("Expected to found MutableSupplyTokenDefinitionParticle or FixedSupplyTokenDefinitionParticle with RRI: \(rri), amongst up particles: \(upParticles), but found none.")
            throw TransferError.foundNoTokenDefinition(forIdentifier: rri)
        }
        
        guard transfer.amount.isExactMultipleOfGranularity(tokenDefinition.granularity) else {
            throw TransferError.amountNotMultipleOfGranularity(amount: transfer.amount, tokenGranularity: tokenDefinition.granularity)
        }
    }
}

internal extension TransferrableTokensParticle {
    static func reducing(particles: [TransferrableTokensParticle]) throws -> [TransferrableTokensParticle] {
        guard let firstParticle = particles.first else { return [] }
        let amount = particles.map { $0.amount.asNonNegative }.reduce(NonNegativeAmount.zero, +)
        let single = try TransferrableTokensParticle(transferrableTokensParticle: firstParticle, amount: amount)
        return [single]
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

private extension FungibleParticleTransitioner where From == TransferrableTokensParticle, To == TransferrableTokensParticle {
    func transition(transfer: TransferTokenAction, upParticles: [AnyUpParticle]) throws -> Transition {
        let rri = transfer.tokenResourceIdentifier
        let upTransferrableParticles = upParticles.compactMap { try? UpParticle<TransferrableTokensParticle>(anyUpParticle: $0) }.filter { $0.particle.tokenDefinitionReference == rri }
        let transferrableTokensParticles = upTransferrableParticles.map { $0.particle }
        let transition: Transition
        do {
            transition = try self.transition(unconsumedFungibles: transferrableTokensParticles, toAmount: transfer.amount.asNonNegative)
        } catch Error.notEnoughFungibles(_, let balance) {
            throw TransferError.insufficientFunds(currentBalance: balance, butTriedToTransfer: transfer.amount)
        }
        return transition
    }
    
    func particlesFrom(transfer: TransferTokenAction, upParticles: [AnyUpParticle]) throws -> [AnySpunParticle] {
        let transition = try self.transition(transfer: transfer, upParticles: upParticles)
        return transition.toSpunParticles()
    }
}
