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

/// Base protocol for `ParticleReducer`, trick to enable easy type-erasure of `ParticleReducer`
public protocol BaseParticleReducer {    
    func anInitialState<S>() -> S where S: ApplicationState
    func reduce<S>(aState: S, upParticle: AnyUpParticle) -> S where S: ApplicationState
}

public protocol ParticleReducer: BaseParticleReducer {
    associatedtype State: ApplicationState
    var initialState: State { get }
    func reduce(state: State, upParticle: AnyUpParticle) -> State
}

public extension ParticleReducer {
    func reduceFromInitialState(upParticles: [AnyUpParticle]) -> State {
        return upParticles.reduce(initialState, reduce)
    }
}

// MARK: - BaseParticleReducer Conformance
public extension ParticleReducer {
    func anInitialState<S>() -> S where S: ApplicationState {
        guard let initial = initialState as? S else {
            incorrectImplementation()
        }
        return initial
    }
    
    func reduce<S>(aState: S, upParticle: AnyUpParticle) -> S where S: ApplicationState {
        let state = castOrKill(instance: aState, toType: State.self)
        let aReducedState = reduce(state: state, upParticle: upParticle)
        return castOrKill(instance: aReducedState, toType: S.self)
     
    }
}

