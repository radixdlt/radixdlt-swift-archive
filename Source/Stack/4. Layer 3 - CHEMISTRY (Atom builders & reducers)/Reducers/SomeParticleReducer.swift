//
//  SomeParticleReducer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct SomeParticleReducer<State: ApplicationState>: ParticleReducer, Throwing {
    
    public let initialState: State
    private let _reduce: (State, AnyUpParticle) -> State
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: ParticleReducer, Concrete.State == State {
        self.initialState = concrete.initialState
        self._reduce = { concrete.reduce(state: $0, upParticle: $1) }
    }
    
    public init(any: AnyParticleReducer) throws {
        guard any.matches(stateType: State.self) else {
            throw Error.stateTypeMismatch
        }
        self.initialState = any.anInitialState()
        self._reduce = { any.reduce(aState: $0, upParticle: $1) }
    }
}

public extension SomeParticleReducer {
    
    enum Error: Int, Swift.Error, Equatable {
        case stateTypeMismatch
    }
    
    func reduce(state: State, upParticle: AnyUpParticle) -> State {
        return self._reduce(state, upParticle)
    }
}
