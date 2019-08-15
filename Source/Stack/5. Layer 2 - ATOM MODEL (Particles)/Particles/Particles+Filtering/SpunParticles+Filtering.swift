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

public extension SpunParticlesOwner {
    
    func upParticles() -> [AnyUpParticle] {
        return spunParticles.compactMap { try? AnyUpParticle(spunParticle: $0) }
    }
    
    func spunParticlesOfType<P>(
        _ type: P.Type,
        spin: Spin? = nil,
        filter: ((P) throws -> Bool)? = nil
        ) rethrows -> [SpunParticle<P>] where P: ParticleConvertible {
        
        let particlesWithCorrectTypeAndSpin = spunParticles
            .filter(spin: spin)
            .compactMap { try? SpunParticle<P>(anySpunParticle: $0) }
        
        guard let filter = filter else { return particlesWithCorrectTypeAndSpin }
        
        return try particlesWithCorrectTypeAndSpin.filter { try filter($0.particle) }
    }
    
    func spunMessageParticles(
        spin: Spin? = nil,
        filter: ((MessageParticle) throws -> Bool)? = nil
        ) rethrows -> [SpunParticle<MessageParticle>] {
        return try spunParticlesOfType(MessageParticle.self, spin: spin) {
            if let filter = filter {
                return try filter($0)
            } else { return true }
        }
    }
    
    func spunUniqueParticles(
        spin: Spin? = nil,
        filter: ((UniqueParticle) throws -> Bool)? = nil
        ) rethrows -> [SpunParticle<UniqueParticle>] {
        return try spunParticlesOfType(UniqueParticle.self, spin: spin) {
            if let filter = filter {
                return try filter($0)
            } else { return true }
        }
    }
    
    func spunRRIParticles(
        spin: Spin? = nil,
        filter: ((ResourceIdentifierParticle) throws -> Bool)? = nil
        ) rethrows -> [SpunParticle<ResourceIdentifierParticle>] {
        return try spunParticlesOfType(ResourceIdentifierParticle.self, spin: spin) {
            if let filter = filter {
                return try filter($0)
            } else { return true }
        }
    }
    
    func spunTransferrableTokensParticles(
        spin: Spin? = nil,
        filter: ((TransferrableTokensParticle) throws -> Bool)? = nil
        ) rethrows -> [SpunParticle<TransferrableTokensParticle>] {
        return try spunParticlesOfType(TransferrableTokensParticle.self, spin: spin) {
            if let filter = filter {
                return try filter($0)
            } else { return true }
        }
    }
    
    func spunUnallocatedTokensParticles(
        spin: Spin? = nil,
        filter: ((UnallocatedTokensParticle) throws -> Bool)? = nil
        ) rethrows -> [SpunParticle<UnallocatedTokensParticle>] {
        return try spunParticlesOfType(UnallocatedTokensParticle.self, spin: spin) {
            if let filter = filter {
                return try filter($0)
            } else { return true }
        }
    }
    
    func spunFixedSupplyTokenDefinitionParticles(
        spin: Spin? = nil,
        filter: ((FixedSupplyTokenDefinitionParticle) throws -> Bool)? = nil
        ) rethrows -> [SpunParticle<FixedSupplyTokenDefinitionParticle>] {
        return try spunParticlesOfType(FixedSupplyTokenDefinitionParticle.self, spin: spin) {
            if let filter = filter {
                return try filter($0)
            } else { return true }
        }
    }
    
    func spunMutableSupplyTokenDefinitionParticles(
        spin: Spin? = nil,
        filter: ((MutableSupplyTokenDefinitionParticle) throws -> Bool)? = nil
        ) rethrows -> [SpunParticle<MutableSupplyTokenDefinitionParticle>] {
        return try spunParticlesOfType(MutableSupplyTokenDefinitionParticle.self, spin: spin) {
            if let filter = filter {
                return try filter($0)
            } else { return true }
        }
    }
    
    // MARK: First Where
    func firstSpunMessageParticle(
        spin: Spin? = nil,
        where filterCondition: ((MessageParticle) throws -> Bool)? = nil
        ) -> SpunParticle<MessageParticle>? {
        return try? spunMessageParticles(spin: spin, filter: filterCondition).first
    }
    
    func firstSpunUniqueParticle(
        spin: Spin? = nil,
        where filterCondition: ((UniqueParticle) throws -> Bool)? = nil
        ) -> SpunParticle<UniqueParticle>? {
        return try? spunUniqueParticles(spin: spin, filter: filterCondition).first
    }
    
    func firstSpunRRIParticle(
        spin: Spin? = nil,
        where filterCondition: ((ResourceIdentifierParticle) throws -> Bool)? = nil
        ) -> SpunParticle<ResourceIdentifierParticle>? {
        return try? spunRRIParticles(spin: spin, filter: filterCondition).first
    }
    
    func firstSpunTransferrableTokensParticle(
        spin: Spin? = nil,
        where filterCondition: ((TransferrableTokensParticle) throws -> Bool)? = nil
        ) -> SpunParticle<TransferrableTokensParticle>? {
        return try? spunTransferrableTokensParticles(spin: spin, filter: filterCondition).first
    }
    
    func firstSpunUnallocatedTokensParticle(
        spin: Spin? = nil,
        where filterCondition: ((UnallocatedTokensParticle) throws -> Bool)? = nil
        ) -> SpunParticle<UnallocatedTokensParticle>? {
        return try? spunUnallocatedTokensParticles(spin: spin, filter: filterCondition).first
    }
    
    func firstSpunFixedSupplyTokenDefinitionParticle(
        spin: Spin? = nil,
        where filterCondition: ((FixedSupplyTokenDefinitionParticle) throws -> Bool)? = nil
        ) -> SpunParticle<FixedSupplyTokenDefinitionParticle>? {
        return try? spunFixedSupplyTokenDefinitionParticles(spin: spin, filter: filterCondition).first
    }
    
    func firstSpunMutableSupplyTokenDefinitionParticle(
        spin: Spin? = nil,
        where filterCondition: ((MutableSupplyTokenDefinitionParticle) throws -> Bool)? = nil
        ) -> SpunParticle<MutableSupplyTokenDefinitionParticle>? {
        return try? spunMutableSupplyTokenDefinitionParticles(spin: spin, filter: filterCondition).first
    }
    
    // MARK: First with RRI
    func firstSpunUniqueParticle(
        matchingIdentifier rri: ResourceIdentifier,
        spin: Spin? = nil
        ) -> SpunParticle<UniqueParticle>? {
        return firstSpunUniqueParticle(spin: spin) { $0.identifier == rri }
    }
    
    func firstSpunMutableSupplyTokenDefinitionParticle(
        matchingIdentifier rri: ResourceIdentifier,
        spin: Spin? = nil
        ) -> SpunParticle<MutableSupplyTokenDefinitionParticle>? {
        return firstSpunMutableSupplyTokenDefinitionParticle(spin: spin) { $0.tokenDefinitionReference == rri }
    }
    
    func firstSpunFixedSupplyTokenDefinitionParticle(
        matchingIdentifier rri: ResourceIdentifier,
        spin: Spin? = nil
        ) -> SpunParticle<FixedSupplyTokenDefinitionParticle>? {
        return firstSpunFixedSupplyTokenDefinitionParticle(spin: spin) { $0.tokenDefinitionReference == rri }
    }
    
    func firstSpunUnallocatedTokensParticle(
        matchingIdentifier rri: ResourceIdentifier,
        spin: Spin? = nil
        ) -> SpunParticle<UnallocatedTokensParticle>? {
        return firstSpunUnallocatedTokensParticle(spin: spin) { $0.tokenDefinitionReference == rri }
    }
    
}
