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
    func reduce<S>(aState: S, particle: ParticleConvertible) -> S where S: ApplicationState
//    func combine<S>(aState lhs: S, withOther rhs: S) -> S where S: ApplicationState
}

public protocol ParticleReducer: BaseParticleReducer {
    associatedtype State: ApplicationState
    var initialState: State { get }
    func reduce(state: State, particle: ParticleConvertible) -> State
//    func combine(state lhs: State, withOther rhs: State) -> State
}

public extension ParticleReducer {
//    func reduceThenCombine(state: State, particle: ParticleConvertible) -> State {
//        let reducedState = reduce(state: state, particle: particle)
//        let combined = combine(state: state, withOther: reducedState)
//        return combined
//    }
    
    func reduceFromInitialState(particles: [ParticleConvertible]) -> State {
        return particles.reduce(initialState, reduce)
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
    
    func reduce<S>(aState: S, particle: ParticleConvertible) -> S where S: ApplicationState {
        guard let state = aState as? State else {
            incorrectImplementation()
        }
        guard let reducedState = reduce(state: state, particle: particle) as? S else {
            incorrectImplementation()
        }
        return reducedState
    }
    
//    func combine<S>(aState lhs: S, withOther rhs: S) -> S where S: ApplicationState {
//        guard let lhsState = lhs as? State, let rhsState = rhs as? State else {
//            incorrectImplementation()
//        }
//        guard let combinedState = combine(state: lhsState, withOther: rhsState) as? S else {
//            incorrectImplementation()
//        }
//        return combinedState
//    }
}

