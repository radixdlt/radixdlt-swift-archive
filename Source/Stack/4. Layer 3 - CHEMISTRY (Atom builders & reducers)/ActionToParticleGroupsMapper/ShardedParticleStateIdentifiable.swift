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

public protocol ShardedParticleStateIdentifiable {
    var particleType: ParticleConvertible.Type { get }
    var address: Address { get }
}

public struct ShardedParticleStateId<Particle>: ShardedParticleStateIdentifiable where Particle: ParticleConvertible {
    public let typeOfParticle: Particle.Type
    public let address: Address
}
public extension ShardedParticleStateId {
    var particleType: ParticleConvertible.Type {
        return typeOfParticle
    }
}

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
