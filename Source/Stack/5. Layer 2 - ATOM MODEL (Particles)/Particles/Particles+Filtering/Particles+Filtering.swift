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

// swiftlint:disable file_length

public extension SpunParticlesOwner {
    func particles() -> [ParticleConvertible] {
        return spunParticles.map { $0.particle }
    }
    
    func particlesOfType<P>(
        _ type: P.Type,
        spin: Spin? = nil,
        filter: ((P) throws -> Bool)? = nil
        ) rethrows -> [P] where P: ParticleConvertible {
        
        let particlesWithCorrectTypeAndSpin = spunParticles
            .filter(spin: spin)
            .compactMap(type: P.self)
        
        guard let filter = filter else { return particlesWithCorrectTypeAndSpin }
        
        return try particlesWithCorrectTypeAndSpin.filter { try filter($0) }
    }
    
    func particles(spin: Spin) -> [ParticleConvertible] {
        return spunParticles
            .filter(spin: spin)
            .map { $0.particle }
    }
    
    func messageParticles(
        spin: Spin? = nil,
        filter: ((MessageParticle) throws -> Bool)? = nil
        ) rethrows -> [MessageParticle] {
        return try particlesOfType(MessageParticle.self, spin: spin) {
            if let filter = filter {
                return try filter($0)
            } else { return true }
        }
    }
    
    func uniqueParticles(
        spin: Spin? = nil,
        filter: ((UniqueParticle) throws -> Bool)? = nil
        ) rethrows -> [UniqueParticle] {
        return try particlesOfType(UniqueParticle.self, spin: spin) {
            if let filter = filter {
                return try filter($0)
            } else { return true }
        }
    }
    
    func rriParticles(
        spin: Spin? = nil,
        filter: ((ResourceIdentifierParticle) throws -> Bool)? = nil
        ) rethrows -> [ResourceIdentifierParticle] {
        return try particlesOfType(ResourceIdentifierParticle.self, spin: spin) {
            if let filter = filter {
                return try filter($0)
            } else { return true }
        }
    }
    
    func transferrableTokensParticles(
        spin: Spin? = nil,
        filter: ((TransferrableTokensParticle) throws -> Bool)? = nil
        ) rethrows -> [TransferrableTokensParticle] {
        return try particlesOfType(TransferrableTokensParticle.self, spin: spin) {
            if let filter = filter {
                return try filter($0)
            } else { return true }
        }
    }
    
    func unallocatedTokensParticles(
        spin: Spin? = nil,
        filter: ((UnallocatedTokensParticle) throws -> Bool)? = nil
        ) rethrows -> [UnallocatedTokensParticle] {
        return try particlesOfType(UnallocatedTokensParticle.self, spin: spin) {
            if let filter = filter {
                return try filter($0)
            } else { return true }
        }
    }
    
    func fixedSupplyTokenDefinitionParticles(
        spin: Spin? = nil,
        filter: ((FixedSupplyTokenDefinitionParticle) throws -> Bool)? = nil
        ) rethrows -> [FixedSupplyTokenDefinitionParticle] {
        return try particlesOfType(FixedSupplyTokenDefinitionParticle.self, spin: spin) {
            if let filter = filter {
                return try filter($0)
            } else { return true }
        }
    }
    
    func mutableSupplyTokenDefinitionParticles(
        spin: Spin? = nil,
        filter: ((MutableSupplyTokenDefinitionParticle) throws -> Bool)? = nil
        ) rethrows -> [MutableSupplyTokenDefinitionParticle] {
        return try particlesOfType(MutableSupplyTokenDefinitionParticle.self, spin: spin) {
            if let filter = filter {
                return try filter($0)
            } else { return true }
        }
    }
    
    // MARK: First Where
    func firstMessageParticle(
        spin: Spin? = nil,
        where filterCondition: ((MessageParticle) throws -> Bool)? = nil
        ) -> MessageParticle? {
        return try? messageParticles(spin: spin, filter: filterCondition).first
    }
    
    func firstUniqueParticle(
        spin: Spin? = nil,
        where filterCondition: ((UniqueParticle) throws -> Bool)? = nil
        ) -> UniqueParticle? {
        return try? uniqueParticles(spin: spin, filter: filterCondition).first
    }
    
    func firstRRIParticle(
        spin: Spin? = nil,
        where filterCondition: ((ResourceIdentifierParticle) throws -> Bool)? = nil
        ) -> ResourceIdentifierParticle? {
        return try? rriParticles(spin: spin, filter: filterCondition).first
    }
    
    func firstTransferrableTokensParticle(
        spin: Spin? = nil,
        where filterCondition: ((TransferrableTokensParticle) throws -> Bool)? = nil
        ) -> TransferrableTokensParticle? {
        return try? transferrableTokensParticles(spin: spin, filter: filterCondition).first
    }
    
    func firstUnallocatedTokensParticle(
        spin: Spin? = nil,
        where filterCondition: ((UnallocatedTokensParticle) throws -> Bool)? = nil
        ) -> UnallocatedTokensParticle? {
        return try? unallocatedTokensParticles(spin: spin, filter: filterCondition).first
    }
    
    func firstFixedSupplyTokenDefinitionParticle(
        spin: Spin? = nil,
        where filterCondition: ((FixedSupplyTokenDefinitionParticle) throws -> Bool)? = nil
        ) -> FixedSupplyTokenDefinitionParticle? {
        return try? fixedSupplyTokenDefinitionParticles(spin: spin, filter: filterCondition).first
    }
    
    func firstMutableSupplyTokenDefinitionParticle(
        spin: Spin? = nil,
        where filterCondition: ((MutableSupplyTokenDefinitionParticle) throws -> Bool)? = nil
        ) -> MutableSupplyTokenDefinitionParticle? {
        return try? mutableSupplyTokenDefinitionParticles(spin: spin, filter: filterCondition).first
    }
    
    // MARK: First with RRI
    func firstUniqueParticle(
        matchingIdentifier rri: ResourceIdentifier,
        spin: Spin? = nil
    ) -> UniqueParticle? {
        return firstUniqueParticle(spin: spin) { $0.identifier == rri }
    }
    
    func firstTransferrableTokensParticle(
        matchingIdentifier rri: ResourceIdentifier,
        spin: Spin? = nil
    ) -> TransferrableTokensParticle? {
        return firstTransferrableTokensParticle(spin: spin) { $0.tokenDefinitionReference == rri }
    }
    
    func firstMutableSupplyTokenDefinitionParticle(
        matchingIdentifier rri: ResourceIdentifier,
        spin: Spin? = nil
        ) -> MutableSupplyTokenDefinitionParticle? {
        return firstMutableSupplyTokenDefinitionParticle(spin: spin) { $0.tokenDefinitionReference == rri }
    }
    
    func firstFixedSupplyTokenDefinitionParticle(
        matchingIdentifier rri: ResourceIdentifier,
        spin: Spin? = nil
        ) -> FixedSupplyTokenDefinitionParticle? {
        return firstFixedSupplyTokenDefinitionParticle(spin: spin) { $0.tokenDefinitionReference == rri }
    }
    
    func firstUnallocatedTokensParticle(
        matchingIdentifier rri: ResourceIdentifier,
        spin: Spin? = nil
    ) -> UnallocatedTokensParticle? {
        return firstUnallocatedTokensParticle(spin: spin) { $0.tokenDefinitionReference == rri }
    }
    
    // MARK: Contains
    func containsAnyMessageParticle(
        spin: Spin? = nil,
        where filterCondition: ((MessageParticle) throws -> Bool)? = nil
    ) -> Bool {
        return firstMessageParticle(spin: spin, where: filterCondition) != nil
    }
    
    func containsAnyTransferrableTokensParticle(
        spin: Spin? = nil,
        where filterCondition: ((TransferrableTokensParticle) throws -> Bool)? = nil
    ) -> Bool {
        return firstTransferrableTokensParticle(spin: spin, where: filterCondition) != nil
    }
    
    func containsAnyUnallocatedTokensParticle(
        spin: Spin? = nil,
        where filterCondition: ((UnallocatedTokensParticle) throws -> Bool)? = nil
    ) -> Bool {
        return firstUnallocatedTokensParticle(spin: spin, where: filterCondition) != nil
    }
    
    func containsAnyUniqueParticle(
        spin: Spin? = nil,
        where filterCondition: ((UniqueParticle) throws -> Bool)? = nil
    ) -> Bool {
        return firstUniqueParticle(spin: spin, where: filterCondition) != nil
    }
    
    func containsAnyFixedSupplyTokenDefinitionParticle(
        spin: Spin? = nil,
        where filterCondition: ((FixedSupplyTokenDefinitionParticle) throws -> Bool)? = nil
    ) -> Bool {
        return firstFixedSupplyTokenDefinitionParticle(spin: spin, where: filterCondition) != nil
    }
    
    func containsAnyMutableSupplyTokenDefinitionParticle(
        spin: Spin? = nil,
        where filterCondition: ((MutableSupplyTokenDefinitionParticle) throws -> Bool)? = nil
    ) -> Bool {
        return firstMutableSupplyTokenDefinitionParticle(spin: spin, where: filterCondition) != nil
    }
    
    // MARK: Contains with RRI
    func containsAnyFixedSupplyTokenDefinitionParticle(
        matchingIdentifier rri: ResourceIdentifier,
        spin: Spin? = nil
    ) -> Bool {
        return containsAnyFixedSupplyTokenDefinitionParticle(spin: spin) { $0.tokenDefinitionReference == rri }
    }
    
    func containsAnyTransferrableTokensParticle(
        matchingIdentifier rri: ResourceIdentifier,
        spin: Spin? = nil
        ) -> Bool {
        return containsAnyTransferrableTokensParticle(spin: spin) { $0.tokenDefinitionReference == rri }
    }
    
    func containsAnyUnallocatedTokensParticle(
        matchingIdentifier rri: ResourceIdentifier,
        spin: Spin? = nil
    ) -> Bool {
        return containsAnyUnallocatedTokensParticle(spin: spin) { $0.tokenDefinitionReference == rri }
    }
    
    func containsAnyMutableSupplyTokenDefinitionParticle(
        matchingIdentifier rri: ResourceIdentifier,
        spin: Spin? = nil
        ) -> Bool {
        return containsAnyMutableSupplyTokenDefinitionParticle(spin: spin) { $0.tokenDefinitionReference == rri }
    }
    
    func containsAnyUniqueParticle(
        matchingIdentifier rri: ResourceIdentifier,
        spin: Spin? = nil
        ) -> Bool {
        return containsAnyUniqueParticle(spin: spin) { $0.identifier == rri }
    }
}

public extension Sequence where Element == Atom {
    func particleGroups() -> [ParticleGroup] {
        return flatMap({ $0.particleGroups })
    }
    
    func spunParticles(spin: Spin? = nil) -> [AnySpunParticle] {
        let particles = particleGroups().flatMap { $0.spunParticles }
        guard let spin = spin else {
            return particles
        }
        return particles.filter(spin: spin)
    }
    
    func upParticles<P>(type: P.Type) -> [P] where P: ParticleConvertible {
        return spunParticles(spin: .up).compactMap(type: type)
    }
    
}

public extension Sequence where Element == AnySpunParticle {
    func compactMap<P>(type: P.Type) -> [P] where P: ParticleConvertible {
        return compactMap { $0.particle as? P }
    }
    
    func filter(spin: Spin?) -> [AnySpunParticle] {
        guard let spin = spin else {
            return [AnySpunParticle](self)
        }
        return filter { $0.spin == spin }
    }
}

public extension Array where Element: SpunParticleContainer {
    func filter(spin: Spin?) -> [Element] {
        guard let spin = spin else {
            return self
        }
        return filter { $0.spin == spin }
    }
}

extension Array: InvertableSpunParticleConvertible where Element: InvertableSpunParticleConvertible {
    public func invertedSpin() -> [Element] {
        return map { $0.invertedSpin() }
    }
}

public extension Sequence where Element == ParticleGroup {
    func firstParticle<P>(ofType type: P.Type, spin: Spin? = nil) -> P? {
        return compactMap { $0.firstParticle(ofType: type, spin: spin) }.first
    }
}

public extension Sequence where Element == AnySpunParticle {
    func firstParticle<P>(ofType type: P.Type, spin: Spin? = nil) -> P? {
        return self.filter(spin: spin).compactMap { $0.particle as? P }.first
    }
}
