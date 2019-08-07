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

public protocol BurnTokensActionToParticleGroupsMapper: StatefulActionToParticleGroupsMapper, Throwing where Action == BurnTokensAction, Error == BurnError {}

public extension BurnTokensActionToParticleGroupsMapper {
    func requiredState(for burnTokensAction: Action) -> [AnyShardedParticleStateId] {
        let tokenDefinitionAddress = burnTokensAction.tokenDefinitionReference.address
        return [
            AnyShardedParticleStateId(
                ShardedParticleStateId(typeOfParticle: TransferrableTokensParticle.self, address: burnTokensAction.burner)
            ),
            
            // To verify that we have a mutable token at the given address
            AnyShardedParticleStateId(
                ShardedParticleStateId(typeOfParticle: MutableSupplyTokenDefinitionParticle.self, address: tokenDefinitionAddress)
            ),
            
            // Include `FixedSupplyTokenDefinitionParticle` to see if the RRI of the token to Burn exists, but has FixedSupply.
            AnyShardedParticleStateId(
                ShardedParticleStateId(typeOfParticle: FixedSupplyTokenDefinitionParticle.self, address: tokenDefinitionAddress)
            )
        ]
    }
}

public final class DefaultBurnTokensActionToParticleGroupsMapper: BurnTokensActionToParticleGroupsMapper {
    public init() {}
}

public enum BurnError: Swift.Error, Equatable {
    
    case unknownToken(identifier: ResourceIdentifier)
    
    case insufficientTokens(
        token: ResourceIdentifier,
        balance: NonNegativeAmount,
        triedToBurnAmount: PositiveAmount
    )
    
    case lackingPermissions(
        of: Address,
        toBurnToken: ResourceIdentifier,
        whichRequiresPermission: TokenPermission,
        creatorOfToken: Address
    )
    
    case tokenHasFixedSupplyThusItCannotBeBurned(
        identifier: ResourceIdentifier
    )
    
    case amountNotMultipleOfGranularity(
        token: ResourceIdentifier,
        triedToBurnAmount: PositiveAmount,
        whichIsNotMultipleOfGranularity: Granularity
    )
}

public extension DefaultBurnTokensActionToParticleGroupsMapper {
   
    func particleGroups(for action: BurnTokensAction, upParticles: [AnyUpParticle]) throws -> ParticleGroups {
        try validateInput(burnAction: action, upParticles: upParticles)
        
        let transitioner = FungibleParticleTransitioner<TransferrableTokensParticle, UnallocatedTokensParticle>(
            transitioner: UnallocatedTokensParticle.init(transferrableTokensParticle:amount:),
            transitionedCombiner: { $0 },
            migrator: TransferrableTokensParticle.init(transferrableTokensParticle:amount:),
            migratedCombiner: TransferrableTokensParticle.reducing(particles:),
            amountMapper: { $0.amount.asNonNegative }
        )
        
        let spunParticles = try transitioner.particlesFrom(burn: action, upParticles: upParticles)
        
        return [
            ParticleGroup(spunParticles: spunParticles)
        ]
    }
}

private extension DefaultBurnTokensActionToParticleGroupsMapper {
    
    func validateInput(burnAction: BurnTokensAction, upParticles: [AnyUpParticle]) throws {
        let rri = burnAction.tokenDefinitionReference
        
        guard let mutableSupplyTokensParticle = upParticles
            .compactMap({ try? UpParticle<MutableSupplyTokenDefinitionParticle>(anyUpParticle: $0) })
            .first(where: { $0.particle.tokenDefinitionReference == rri })
            .map({ $0.particle }) else {
                
                let foundFixedSupplyTokenWithMatchingIdentifier = upParticles
                    .compactMap({ try? UpParticle<FixedSupplyTokenDefinitionParticle>(anyUpParticle: $0) })
                    .first(where: { $0.particle.tokenDefinitionReference == rri }) != nil
                
                if foundFixedSupplyTokenWithMatchingIdentifier {
                    throw Error.tokenHasFixedSupplyThusItCannotBeBurned(identifier: rri)
                } else {
                    throw Error.unknownToken(identifier: rri)
                }
        }
        
        guard mutableSupplyTokensParticle.canBeBurned(by: burnAction.burner) else {
            throw Error.lackingPermissions(
                of: burnAction.burner,
                toBurnToken: rri,
                whichRequiresPermission: mutableSupplyTokensParticle.permissions.mintPermission,
                creatorOfToken: mutableSupplyTokensParticle.address
            )
        }
        
        let burnAmount = burnAction.amount
        let granularity = mutableSupplyTokensParticle.granularity
        guard burnAmount.isExactMultipleOfGranularity(granularity) else {
            throw Error.amountNotMultipleOfGranularity(
                token: rri,
                triedToBurnAmount: burnAmount,
                whichIsNotMultipleOfGranularity: granularity
            )
        }
        
        // All is well.
    }
}

// swiftlint:disable opening_brace
private extension FungibleParticleTransitioner where
    From == TransferrableTokensParticle,
    To == UnallocatedTokensParticle
{
    // swiftlint:enable opening_brace
    
    func transition(burn: BurnTokensAction, upParticles: [AnyUpParticle]) throws -> Transition {
        let rri = burn.tokenDefinitionReference
        
        let upTransferrableTokensParticles = upParticles
            .compactMap { try? UpParticle<TransferrableTokensParticle>(anyUpParticle: $0) }
            .filter { $0.particle.tokenDefinitionReference == rri }
        
        let transferrableTokensParticles = upTransferrableTokensParticles.map { $0.particle }
        
        let transition: Transition
        do {
            transition = try self.transition(unconsumedFungibles: transferrableTokensParticles, toAmount: burn.amount.asNonNegative)
        } catch Error.notEnoughFungibles(_, let balance) {
         
            throw BurnError.insufficientTokens(
                token: rri,
                balance: balance,
                triedToBurnAmount: burn.amount
            )
        }
        return transition
    }
    
    func particlesFrom(burn: BurnTokensAction, upParticles: [AnyUpParticle]) throws -> [AnySpunParticle] {
        let transition = try self.transition(burn: burn, upParticles: upParticles)
        return transition.toSpunParticles()
    }
}
