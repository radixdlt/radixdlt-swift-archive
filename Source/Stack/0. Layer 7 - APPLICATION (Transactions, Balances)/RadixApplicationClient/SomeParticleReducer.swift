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
    private let _reduce: (State, ParticleConvertible) -> State
    private let _combine: (State, State) -> State
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: ParticleReducer, Concrete.State == State {
        self.initialState = concrete.initialState
        self._reduce = { concrete.reduce(state: $0, particle: $1) }
        self._combine = { concrete.combine(state: $0, withOther: $1) }
    }
    
    public init(any: AnyParticleReducer) throws {
        guard any.matches(stateType: State.self) else {
            throw Error.stateTypeMismatch
        }
        self.initialState = any.anInitialState()
        self._reduce = { any.reduce(aState: $0, particle: $1) }
        self._combine = { any.combine(aState: $0, withOther: $1) }
    }
}

public extension SomeParticleReducer {
    
    enum Error: Int, Swift.Error, Equatable {
        case stateTypeMismatch
    }
    
    func reduce(state: State, particle: ParticleConvertible) -> State {
        return self._reduce(state, particle)
    }
    
    func combine(state lhs: State, withOther rhs: State) -> State {
        return self._combine(lhs, rhs)
    }
}
