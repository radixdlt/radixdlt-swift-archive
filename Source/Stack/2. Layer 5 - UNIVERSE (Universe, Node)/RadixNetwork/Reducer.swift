/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

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
