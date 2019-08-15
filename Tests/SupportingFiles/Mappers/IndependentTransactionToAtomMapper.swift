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

struct IndependentTransactionToAtomMapper: TransactionToAtomMapper {
    
    private let actionMappers: [AnyStatefulActionToParticleGroupsMapper]
    
    init() {
        let statelessActionToParticleGroupsMappers: [AnyStatelessActionToParticleGroupsMapper] = .default
        let statefulActionToParticleGroupsMappers: [AnyStatefulActionToParticleGroupsMapper] = .default
        
        self.actionMappers = {
            let statefulFromStateless = statelessActionToParticleGroupsMappers.map {
                AnyStatefulActionToParticleGroupsMapper(anyStatelessMapper: $0)
            }
            return statefulActionToParticleGroupsMappers + statefulFromStateless
        }()
    }
    
    func atomFrom(transaction: Transaction, addressOfActiveAccount: Address) throws -> Atom {
        var upParticlesFromTx = [AnyUpParticle]()
        
        var particleGroupsFromTx = [ParticleGroup]()
        
        for action in transaction.actions {
            let statefulMapper = actionMapperFor(action: action)
            let particleGroups = try statefulMapper.particleGroupsForAnAction(action, upParticles: upParticlesFromTx, addressOfActiveAccount: addressOfActiveAccount)
            
            for particleGroup in particleGroups {
                
                let upParticlesFromAction = try particleGroup.spunParticles.filter(spin: .up).map(AnyUpParticle.init(spunParticle:))
                
                upParticlesFromTx.append(contentsOf: upParticlesFromAction)
            }
            
            particleGroupsFromTx.append(contentsOf: particleGroups)
        }
        
        return Atom(particleGroups: ParticleGroups(particleGroupsFromTx))
    }
}

private extension IndependentTransactionToAtomMapper {
    func actionMapperFor(action: UserAction) -> AnyStatefulActionToParticleGroupsMapper {
        guard let mapper = actionMappers.first(where: { $0.matches(someAction: action) }) else {
            incorrectImplementation("Found no ActionToParticleGroupsMapper for action: \(action), you probably just added a new UserAction but forgot to add its corresponding mapper to the list?")
        }
        return mapper
    }
}
