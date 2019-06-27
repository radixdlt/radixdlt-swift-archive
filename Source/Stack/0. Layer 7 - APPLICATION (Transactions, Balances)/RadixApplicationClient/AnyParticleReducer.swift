//
//  AnyParticleReducer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct AnyParticleReducer: BaseParticleReducer {
    
    private let _stateType: () -> Any.Type
    private let _matchesType: (Any.Type) -> Bool
    private let _initialState: () -> Any
    private let _reduce: (Any, ParticleConvertible) -> Any
    private let _combine: (Any, Any) -> Any
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: ParticleReducer {
        // swiftlint:disable:next identifier_name
        let State = Concrete.State.self
        self._stateType = { State }
        self._matchesType = { return $0 == State }
        self._initialState = { concrete.initialState }
        self._reduce = {
            let state = castOrKill(instance: $0, toType: State)
            return concrete.reduce(state: state, particle: $1)
        }
        self._combine = {
            let (lhsState, rhsState) = castOrKill(instance: $0, and: $1, toType: State)
            return concrete.combine(state: lhsState, withOther: rhsState)
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
    
    func reduce<S>(aState: S, particle: ParticleConvertible) -> S where S: ApplicationState {
        return castOrKill(
            instance: self._reduce(aState, particle),
            toType: S.self
        )
    }
    
    func combine<S>(aState lhs: S, withOther rhs: S) -> S where S: ApplicationState {
        return castOrKill(
            instance: self._combine(lhs, rhs),
            toType: S.self
        )
    }
}

