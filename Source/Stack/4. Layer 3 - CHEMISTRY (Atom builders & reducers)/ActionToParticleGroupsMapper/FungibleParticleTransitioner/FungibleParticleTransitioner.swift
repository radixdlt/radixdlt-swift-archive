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

public final class FungibleParticleTransitioner<From, To>: Throwing where From: ParticleConvertible, To: ParticleConvertible {
    
    private let transitioner: (From, NonNegativeAmount) throws -> To
    private let transitionedCombiner: ([To]) throws -> [To]
    private let migrator: (From, NonNegativeAmount) throws -> From
    private let migratedCombiner: ([From]) throws -> [From]
    private let amountMapper: (From) throws -> NonNegativeAmount
    
    private var removed = [From]()
    private var migrated = [From]()
    private var transitioned = [To]()
    
    public init(
        transitioner: @escaping (From, NonNegativeAmount) throws -> To,
        transitionedCombiner: @escaping ([To]) throws -> [To],
        migrator: @escaping (From, NonNegativeAmount) throws -> From,
        migratedCombiner: @escaping ([From]) throws -> [From],
        amountMapper: @escaping (From) throws -> NonNegativeAmount
    ) {
        self.amountMapper = amountMapper
        
        self.transitioner = transitioner
        self.transitionedCombiner = transitionedCombiner
        self.migrator = migrator
        self.migratedCombiner = migratedCombiner
    }
}

public extension FungibleParticleTransitioner where To == From {
    convenience init(
        transitioner: @escaping (From, NonNegativeAmount) throws -> To,
        transitionAndMigrateCombiner: @escaping ([From]) throws -> [To],
        migrator: @escaping (From, NonNegativeAmount) throws -> From,
        amountMapper: @escaping (From) throws -> NonNegativeAmount
    ) {
        self.init(
            transitioner: transitioner,
            transitionedCombiner: { try transitionAndMigrateCombiner($0) },
            migrator: migrator,
            migratedCombiner: { try transitionAndMigrateCombiner($0) },
            amountMapper: amountMapper
        )
    }
}

public extension FungibleParticleTransitioner {
    struct Transition {
        public let removed: [From]
        public let migrated: [From]
        public let transitioned: [To]
    }
}

public extension FungibleParticleTransitioner.Transition {
    func toSpunParticles() -> [AnySpunParticle] {
        var particles = [AnySpunParticle]()
        particles.append(contentsOf: self.removed.map { $0.withSpin(.down) })
        particles.append(contentsOf: self.migrated.map { $0.withSpin(.up) })
        particles.append(contentsOf: self.transitioned.map { $0.withSpin(.up) })
        
        return particles
    }
}

private extension FungibleParticleTransitioner {
    
    func transition(amount: NonNegativeAmount, fungible: From) throws {
        transitioned.append(
            try transitioner(fungible, amount)
        )
    }
    
    func migrate(amount: NonNegativeAmount, fungible: From) throws {
        migrated.append(
            try migrator(fungible, amount)
        )
    }
    
    func remove(fungible: From) {
        removed.append(fungible)
    }
    
    func finalize() -> FungibleParticleTransitioner.Transition {
        return FungibleParticleTransitioner.Transition(removed: removed, migrated: migrated, transitioned: transitioned)
    }
}

public extension FungibleParticleTransitioner {
    enum Error: Swift.Error, Equatable {
        case notEnoughFungibles(requiredAmount: NonNegativeAmount, butOnlyGotBalance: NonNegativeAmount)
    }
}

public extension FungibleParticleTransitioner {
    
    func transition(unconsumedFungibles: [From], toAmount: NonNegativeAmount) throws -> Transition {
        let balance: NonNegativeAmount = try unconsumedFungibles
            .map(amountMapper)
            .reduce(NonNegativeAmount.zero, +)
        
        guard balance >= toAmount else {
            throw Error.notEnoughFungibles(requiredAmount: toAmount, butOnlyGotBalance: balance)
        }
        var comsumerTotal: NonNegativeAmount = .zero
        
        let isToAmountCoveredYet = { comsumerTotal >= toAmount }
        
        for unconsumedFungible in unconsumedFungibles where !isToAmountCoveredYet() {
            
            // Should be non negative thanks to `where !isToAmountCoveredYet` check
            let left: NonNegativeAmount = toAmount - comsumerTotal
            let particleAmount = try amountMapper(unconsumedFungible)
            comsumerTotal += particleAmount
            
            let amountToTransfer = min(left, particleAmount)
            let amountToKeep = particleAmount - amountToTransfer
            
            try transition(amount: amountToTransfer, fungible: unconsumedFungible)
            if amountToKeep > 0 {
                try migrate(amount: amountToKeep, fungible: unconsumedFungible)
            }
            remove(fungible: unconsumedFungible)
        }
        
        return finalize()
    }
}

