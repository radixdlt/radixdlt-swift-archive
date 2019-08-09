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

public protocol MintTokensActionToParticleGroupsMapper: StatefulActionToParticleGroupsMapper where Action == MintTokensAction {}

public extension MintTokensActionToParticleGroupsMapper {
    func requiredState(for mintTokensAction: Action) -> [AnyShardedParticleStateId] {
        let tokenDefinitionAddress = mintTokensAction.tokenDefinitionReference.address
        return [
            AnyShardedParticleStateId(
                ShardedParticleStateId(typeOfParticle: UnallocatedTokensParticle.self, address: tokenDefinitionAddress)
            ),
            
            AnyShardedParticleStateId(
                ShardedParticleStateId(typeOfParticle: MutableSupplyTokenDefinitionParticle.self, address: tokenDefinitionAddress)
            ),
            
            // Include `FixedSupplyTokenDefinitionParticle` to see if the RRI of the token to Mint exists, but has FixedSupply.
            AnyShardedParticleStateId(
                ShardedParticleStateId(typeOfParticle: FixedSupplyTokenDefinitionParticle.self, address: tokenDefinitionAddress)
            )
        ]
    }
}

public final class DefaultMintTokensActionToParticleGroupsMapper: MintTokensActionToParticleGroupsMapper, Throwing {
    public init() {}
}

public extension DefaultMintTokensActionToParticleGroupsMapper {
    
    typealias Action = MintTokensAction
    
    func particleGroups(for action: Action, upParticles: [AnyUpParticle], addressOfActiveAccount: Address) throws -> ParticleGroups {
        try validateInput(mintAction: action, upParticles: upParticles)
        
        let transitioner = FungibleParticleTransitioner<UnallocatedTokensParticle, TransferrableTokensParticle>(
            transitioner: { try TransferrableTokensParticle(unallocatedTokensParticle: $0, amount: $1, address: action.creditNewlyMintedTokensTo) },
            transitionedCombiner: { $0 },
            migrator: UnallocatedTokensParticle.init(unallocatedTokensParticle:amount:),
            migratedCombiner: { $0 },
            amountMapper: { $0.amount.amount }
        )
        
        let spunParticles = try transitioner.particlesFrom(mint: action, upParticles: upParticles)
        
        return [
            ParticleGroup(spunParticles: spunParticles)
        ]
    }
}

// MARK: - Throwing
public extension DefaultMintTokensActionToParticleGroupsMapper {
    typealias Error = MintError
}

public enum MintError: Swift.Error, Equatable {
    
    case unknownToken(identifier: ResourceIdentifier)
    
    case tokenOverMint(
        token: ResourceIdentifier,
        maxSupply: Supply,
        currentSupply: Supply,
        byMintingAmount: PositiveAmount
    )
    
    case lackingPermissions(
        of: Address,
        toMintToken: ResourceIdentifier,
        whichRequiresPermission: TokenPermission,
        creatorOfToken: Address
    )
    
    case tokenHasFixedSupplyThusItCannotBeMinted(
        identifier: ResourceIdentifier
    )
    
    case amountNotMultipleOfGranularity(
        token: ResourceIdentifier,
        triedToMintAmount: PositiveAmount,
        whichIsNotMultipleOfGranularity: Granularity
    )
}

private extension DefaultMintTokensActionToParticleGroupsMapper {
    
    func validateInput(mintAction: MintTokensAction, upParticles: [AnyUpParticle]) throws {
        let rri = mintAction.tokenDefinitionReference

        guard let mutableSupplyTokensParticle = upParticles.firstMutableSupplyTokenDefinitionParticle(matchingIdentifier: rri) else {
            if upParticles.containsAnyFixedSupplyTokenDefinitionParticle(matchingIdentifier: rri) {
                throw Error.tokenHasFixedSupplyThusItCannotBeMinted(identifier: rri)
            } else {
                throw Error.unknownToken(identifier: rri)
            }
        }
        
        guard mutableSupplyTokensParticle.canBeMinted(by: mintAction.minter) else {
            throw Error.lackingPermissions(
                of: mintAction.minter,
                toMintToken: rri,
                whichRequiresPermission: mutableSupplyTokensParticle.permissions.mintPermission,
                creatorOfToken: mutableSupplyTokensParticle.address
            )
        }
        
        let mintAmount = mintAction.amount
        let granularity = mutableSupplyTokensParticle.granularity
        guard mintAmount.isExactMultipleOfGranularity(granularity) else {
            throw Error.amountNotMultipleOfGranularity(
                token: rri,
                triedToMintAmount: mintAmount,
                whichIsNotMultipleOfGranularity: granularity
            )
        }
        
        // All is well.
    }
}

private extension FungibleParticleTransitioner where From == UnallocatedTokensParticle, To == TransferrableTokensParticle {
    func transition(mint: MintTokensAction, upParticles: [AnyUpParticle]) throws -> Transition {
        let rri = mint.tokenDefinitionReference
        
        let unallocatedTokensParticles = upParticles.unallocatedTokensParticles { $0.tokenDefinitionReference == rri }
        
        let transition: Transition
        do {
            transition = try self.transition(unconsumedFungibles: unallocatedTokensParticles, toAmount: mint.amount.asNonNegative)
        } catch Error.notEnoughFungibles(_, let balance) {
            
            guard let currentSupply = try? Supply(subtractingFromMax: balance) else {
                incorrectImplementation("Should alsways be able to derive current supply.")
            }
            
            throw MintError.tokenOverMint(
                token: rri,
                maxSupply: .max,
                currentSupply: currentSupply,
                byMintingAmount: mint.amount
            )
        }
        return transition
    }
    
    func particlesFrom(mint: MintTokensAction, upParticles: [AnyUpParticle]) throws -> [AnySpunParticle] {
        let transition = try self.transition(mint: mint, upParticles: upParticles)
        return transition.toSpunParticles()
    }
}
