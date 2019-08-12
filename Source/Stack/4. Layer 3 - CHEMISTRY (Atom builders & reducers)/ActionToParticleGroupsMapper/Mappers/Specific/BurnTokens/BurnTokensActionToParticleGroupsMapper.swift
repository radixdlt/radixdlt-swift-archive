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

public protocol BurnTokensActionToParticleGroupsMapper: ConsumeTokenActionToParticleGroupsMapper, Throwing where Action == BurnTokensAction, Error == BurnError {}

public enum BurnError: ConsumeTokensActionErrorInitializable {
    
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
    
    case consumeError(ConsumeTokensActionError)
}

public extension BurnError {
    static func errorFrom(consumeTokensActionError: ConsumeTokensActionError) -> BurnError {
        return .consumeError(consumeTokensActionError)
    }
}

public extension DefaultBurnTokensActionToParticleGroupsMapper {
   
    func particleGroups(for action: BurnTokensAction, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws -> ParticleGroups {
        try validateInputMappingConsumeTokensActionError(action: action, upParticles: upParticles, addressOfActiveAccount: addressOfActiveAccount)
        
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
    
    func validateConsumeTokenAction(
        _ action: Action,
        consumeTokensContext: ConsumeTokensContext
    ) throws {
    
        let rri = action.tokenDefinitionReference
        switch consumeTokensContext {
        case .fixedSupplyTokenDefinitionParticle:
            throw Error.tokenHasFixedSupplyThusItCannotBeBurned(identifier: rri)
        case .mutableSupplyTokenDefinitionParticle(let mutableSupplyTokenDefinitionsParticle):
            guard mutableSupplyTokenDefinitionsParticle.canBeBurned(by: action.burner) else {
                throw Error.lackingPermissions(
                    of: action.burner,
                    toBurnToken: rri,
                    whichRequiresPermission: mutableSupplyTokenDefinitionsParticle.permissions.mintPermission,
                    creatorOfToken: mutableSupplyTokenDefinitionsParticle.address
                )
            }
            
        }
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
        
        let transferrableTokensParticles = upParticles.transferrableTokensParticles { $0.tokenDefinitionReference == rri }
        
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
