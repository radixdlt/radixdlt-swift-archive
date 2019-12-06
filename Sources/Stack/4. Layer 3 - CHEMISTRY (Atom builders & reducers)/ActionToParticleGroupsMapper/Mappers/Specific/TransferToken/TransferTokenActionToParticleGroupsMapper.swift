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

// swiftlint:disable opening_brace

public protocol TransferTokensActionToParticleGroupsMapper: ConsumeTokenActionToParticleGroupsMapper
    where
    Action == TransferTokensAction,
    SpecificActionError == TransferError
{}

// swiftlint:enable opening_brace

// MARK: - Default Implementation
public extension TransferTokensActionToParticleGroupsMapper {
    
    func mapError(_ transferError: TransferError, action transferTokensAction: TransferTokensAction) -> ActionsToAtomError {
        ActionsToAtomError.transferTokensActionError(transferError, action: transferTokensAction)
    }
    
    func particleGroups(
        for transfer: TransferTokensAction,
        upParticles: [AnyUpParticle],
        addressOfActiveAccount: Address
    ) throws -> Throws<ParticleGroups, TransferError> {
        
        do {
            try validateInputMappingConsumeTokensActionError(action: transfer, upParticles: upParticles, addressOfActiveAccount: addressOfActiveAccount)
            
            let transitioner = FungibleParticleTransitioner<TransferrableTokensParticle, TransferrableTokensParticle>(
                transitioner: { try TransferrableTokensParticle(transferrableTokensParticle: $0, amount: $1, address: transfer.recipient) },
                transitionAndMigrateCombiner: TransferrableTokensParticle.reducing(particles:),
                migrator: TransferrableTokensParticle.init(transferrableTokensParticle:amount:),
                amountMapper: { NonNegativeAmount(subset: $0.amount) }
            )
            
            let particles = try transitioner.particlesFrom(transfer: transfer, upParticles: upParticles)
            
            let particleGroup = try ParticleGroup(spunParticles: particles, metaData: transfer.metaDataFromAttachmentOrEmpty)
            
            return [particleGroup]
        } catch let transferError as TransferError {
            throw transferError
        } catch {
            unexpectedlyMissedToCatch(error: error)
        }
    }
}

// MARK: - Internal

// MARK: TransferrableTokensParticle + Reduce
internal extension TransferrableTokensParticle {
    static func reducing(particles: [TransferrableTokensParticle]) throws -> [TransferrableTokensParticle] {
        guard let firstParticle = particles.first else { return [] }
        let single = try TransferrableTokensParticle(transferrableTokensParticle: firstParticle, amount: NonNegativeAmount.fromTransferrableTokens(particles: particles))
        return [single]
    }

}

// MARK: - Private

// MARK: FungibleParticleTransitioner
private extension FungibleParticleTransitioner where From == TransferrableTokensParticle, To == TransferrableTokensParticle {
    func transition(transfer: TransferTokensAction, upParticles: [AnyUpParticle]) throws -> Transition {
        let rri = transfer.tokenResourceIdentifier
        
        let transferrableTokensParticles = upParticles.transferrableTokensParticles { $0.tokenDefinitionReference == rri }
        
        let transition: Transition
        do {
            transition = try self.transition(
                unconsumedFungibles: transferrableTokensParticles,
                toAmount: NonNegativeAmount(subset: transfer.amount)
            )
        } catch Error.notEnoughFungibles(_, let balance) {
            throw TransferError.insufficientFunds(currentBalance: balance, butTriedToTransfer: transfer.amount)
        }
        return transition
    }
    
    func particlesFrom(transfer: TransferTokensAction, upParticles: [AnyUpParticle]) throws -> [AnySpunParticle] {
        let transition = try self.transition(transfer: transfer, upParticles: upParticles)
        return transition.toSpunParticles()
    }
}
