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

public struct AnyShardedParticleStateId: ShardedParticleStateIdentifiable {
    
    private let _getParticleType: () -> ParticleConvertible.Type
    public let address: Address
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: ShardedParticleStateIdentifiable {
        self.address = concrete.address
        self._getParticleType = { concrete.particleType }
    }
}

public extension AnyShardedParticleStateId {
    var particleType: ParticleConvertible.Type {
        return _getParticleType()
    }
}

// MARK: Presets
public extension AnyShardedParticleStateId {
    static func stateForUniqueIdentifier(address: Address) -> [AnyShardedParticleStateId] {
        return [
            // To verify that we haven't already used that RRI for UniqueId
            AnyShardedParticleStateId(
                ShardedParticleStateId(typeOfParticle: UniqueParticle.self, address: address)
            ),
            
            // To verify that we haven't already used that RRI for MutableSupplyTokenDefinitionParticle
            AnyShardedParticleStateId(
                ShardedParticleStateId(
                    typeOfParticle: MutableSupplyTokenDefinitionParticle.self,
                    address: address
                )
            ),
            
            // To verify that we haven't already used that RRI for FixedSupplyTokenDefinitionParticle
            AnyShardedParticleStateId(
                ShardedParticleStateId(
                    typeOfParticle: FixedSupplyTokenDefinitionParticle.self,
                    address: address
                )
            )
        ]
    }
    
    static func stateConsumingTokens(actor: Address, tokenIdentifier: ResourceIdentifier) -> [AnyShardedParticleStateId] {
        let tokenDefinitionAddress = tokenIdentifier.address
        return [
            AnyShardedParticleStateId(
                ShardedParticleStateId(typeOfParticle: TransferrableTokensParticle.self, address: actor)
            ),
            
            // To verify that we have a mutable token at the given address
            AnyShardedParticleStateId(
                ShardedParticleStateId(typeOfParticle: MutableSupplyTokenDefinitionParticle.self, address: tokenDefinitionAddress)
            ),
            
            // Include `FixedSupplyTokenDefinitionParticle` to see if the RRI of the token to consume exists, but has FixedSupply.
            AnyShardedParticleStateId(
                ShardedParticleStateId(typeOfParticle: FixedSupplyTokenDefinitionParticle.self, address: tokenDefinitionAddress)
            )
        ]
    }
}
