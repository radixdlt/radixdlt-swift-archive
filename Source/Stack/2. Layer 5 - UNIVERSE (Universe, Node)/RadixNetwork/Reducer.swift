//
//  Reducer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol BaseReducer {
    func reduce(anAction: Any)
}

public protocol Reducer: BaseReducer {
    associatedtype Action
    func reduce(action: Action)
}

public extension Reducer {
    
    func reduce(anAction: Any) {
        let action = castOrKill(instance: anAction, toType: Action.self)
        reduce(action: action)
    }
}

public struct SomeReducer<Action>: Reducer, Throwing {
    private let _reduce: (Action) -> Void
    init<Concrete>(_ concrete: Concrete) where Concrete: Reducer, Concrete.Action == Action {
        self._reduce = { concrete.reduce(action: $0) }
    }
    init(any: AnyReducer) throws {
        guard any.matches(actionType: Action.self) else {
            throw Error.actionTypeMismatch
        }
        self._reduce = { any.reduce(anAction: $0) }
    }
}
public extension SomeReducer {
    func reduce(action: Action) {
        self._reduce(action)
    }
}

public extension SomeReducer {
    enum Error: Int, Swift.Error, Equatable {
        case actionTypeMismatch
    }
}

public struct AnyReducer: BaseReducer {
    private let _actionType: () -> Any.Type
    private let _matchesType: (Any.Type) -> Bool
    private let _reduce: (Any) -> Void
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: Reducer {
        self._actionType = { Concrete.Action.self }
        self._matchesType = { return $0 == Concrete.Action.self }
        self._reduce = {
            let action = castOrKill(instance: $0, toType: Concrete.Action.self)
            concrete.reduce(action: action)
        }
    }
}

public extension AnyReducer {
    
    func reduce(anAction: Any) {
        self._reduce(anAction)
    }
    
    func matches<Action>(actionType: Action.Type) -> Bool {
        return _matchesType(actionType)
    }
    
    var actionType: Any.Type {
        return _actionType()
    }
}
