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

public protocol ParticleContainer {
    var someParticle: ParticleConvertible { get }
}

public protocol SpunParticleContainer: ParticleContainer {
    var spin: Spin { get }
}

public struct SpunParticle<Particle>: SpunParticleContainer, Throwing where Particle: ParticleConvertible {
    
    public let spin: Spin
    public let particle: Particle
    
    private init(spin: Spin, particle: Particle) {
        self.spin = spin
        self.particle = particle
    }
    
    public init(anySpunParticle: AnySpunParticle) throws {
        guard let particle = anySpunParticle.particle as? Particle else {
            throw Error.particleTypeMismatch
        }
        self.init(spin: anySpunParticle.spin, particle: particle)
    }
}

public extension SpunParticle {
    enum Error: Swift.Error, Equatable {
        case particleTypeMismatch
    }
}

public extension SpunParticle {
    var someParticle: ParticleConvertible { return particle }
}

public struct UpParticle<Particle>: SpunParticleContainer, Throwing where Particle: ParticleConvertible {
    
    public let particle: Particle
    
    public init(spunParticle: SpunParticle<Particle>) throws {
        guard spunParticle.spin == .up else {
            throw Error.particleDidNotHaveSpinUp
        }
        self.particle = spunParticle.particle
    }
    
    public init(anySpunParticle: AnySpunParticle) throws {
        guard anySpunParticle.spin == .up else {
            throw Error.particleDidNotHaveSpinUp
        }
        guard let particle = anySpunParticle.particle as? Particle else {
            throw Error.particleTypeMismatch
        }
        self.particle = particle
    }
    
    public init(anyUpParticle: AnyUpParticle) throws {
        guard let particle = anyUpParticle.someParticle as? Particle else {
            throw Error.particleTypeMismatch
        }
        self.particle = particle
    }
}

public extension UpParticle {
    var someParticle: ParticleConvertible { return particle }
    var spin: Spin { return .up }
}

public extension UpParticle {
    enum Error: Swift.Error, Equatable {
        case particleDidNotHaveSpinUp
        case particleTypeMismatch
    }
}

public struct AnyUpParticle: SpunParticleContainer, Throwing {
    public let someParticle: ParticleConvertible
    
    /// Only use this initializer when you KNOW for sure that the spin is `Up`.
    internal init(particle: ParticleConvertible) {
        self.someParticle = particle
    }
 
    public init(anySpunParticle: AnySpunParticle) throws {
        guard anySpunParticle.spin == .up else {
            throw Error.particleDidNotHaveSpinUp
        }
    
        self.init(particle: anySpunParticle.particle)
    }
    
}

public extension AnyUpParticle {
    var spin: Spin { return .up }
}

extension Array: SpunParticlesOwner where Element: SpunParticleContainer {
    public var spunParticles: [AnySpunParticle] {
        return map { AnySpunParticle(spin: $0.spin, particle: $0.someParticle) }
    }
}

//public protocol SpunParticlesOwner {
//    var spunParticles: [AnySpunParticle] { get }
//}

public extension AnyUpParticle {
    enum Error: Swift.Error, Equatable {
        case particleDidNotHaveSpinUp
    }
}
