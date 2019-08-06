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

public struct AnyParticleReducer: BaseParticleReducer {
    
    private let _stateType: () -> Any.Type
    private let _matchesType: (Any.Type) -> Bool
    private let _initialState: () -> Any
    private let _reduce: (Any, AnyUpParticle) throws -> Any
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: ParticleReducer {
        // swiftlint:disable:next identifier_name
        let State = Concrete.State.self
        self._stateType = { State }
        self._matchesType = { return $0 == State }
        self._initialState = { concrete.initialState }
        self._reduce = {
            let state = castOrKill(instance: $0, toType: State)
            return try concrete.reduce(state: state, upParticle: $1)
        }
    }
}

public extension AnyParticleReducer {
    
    func matches<State>(stateType: State.Type) -> Bool where State: ApplicationState {
        return _matchesType(stateType)
    }
    
    var stateType: Any.Type {
        return _stateType()
    }
    
    func anInitialState<S>() -> S where S: ApplicationState {
        return castOrKill(
            instance: self._initialState(),
            toType: S.self
        )
    }
    
    func reduce<S>(aState: S, upParticle: AnyUpParticle) throws -> S where S: ApplicationState {
        return castOrKill(
            instance: try self._reduce(aState, upParticle),
            toType: S.self
        )
    }
}

