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

public final class DefaultParticlesToStateReducer: ParticlesToStateReducer {
    
    /// A list of type-erased reducers of `Particle`s into `ApplicationState`, from which we can derive e.g. token balance and token definitions.
    private let particlesToStateReducers: [AnyParticleReducer]
    
    public init(
        particlesToStateReducers: [AnyParticleReducer] = .default
    ) {
        self.particlesToStateReducers = particlesToStateReducers
    }
}

private extension DefaultParticlesToStateReducer {
    func particlesToStateReducer<State>(for stateType: State.Type) -> SomeParticleReducer<State> where State: ApplicationState {
        guard let reducer = particlesToStateReducers.first(where: {  $0.matches(stateType: stateType) }) else {
            incorrectImplementation("Found no ParticleReducer for state of type: \(stateType), you probably just added a new ApplicationState but forgot to add its corresponding reducer to the list?")
        }
        do {
            return try SomeParticleReducer<State>(any: reducer)
        } catch { unexpectedlyMissedToCatch(error: error) }
    }
}

public extension DefaultParticlesToStateReducer {
    
    func reduce<State>(upParticles: [AnyUpParticle], to stateType: State.Type) throws -> State where State: ApplicationState {
        let reducer = particlesToStateReducer(for: stateType)
        return try reducer.reduceFromInitialState(upParticles: upParticles)
    }
    
}

// MARK: Default reducers
public extension Array where Element == AnyParticleReducer {
    static var `default`: [AnyParticleReducer] {
        return [
            AnyParticleReducer(TokenBalanceReferencesReducer()),
            AnyParticleReducer(TokenDefinitionsReducer())
        ]
    }
}
