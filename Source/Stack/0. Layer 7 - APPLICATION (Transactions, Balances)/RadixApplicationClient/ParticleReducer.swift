//
//  BaseParticleReducer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
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

