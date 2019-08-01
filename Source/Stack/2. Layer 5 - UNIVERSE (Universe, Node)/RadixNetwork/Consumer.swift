//
//  Consumer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol BaseConsumer {
    func acceptAnArgument(_ anArgument: Any)
}

public protocol Consumer: BaseConsumer {
    associatedtype Argument
    func accept(_ argument: Argument)
}

public extension Consumer {
    
    func acceptAnArgument(_ anArgument: Any) {
        let argument = castOrKill(instance: anArgument, toType: Argument.self)
        accept(argument)
    }
}

public struct SomeConsumer<Argument>: Consumer, Throwing {
    private let _accept: (Argument) -> Void
    init<Concrete>(_ concrete: Concrete) where Concrete: Consumer, Concrete.Argument == Argument {
        self._accept = { concrete.accept($0) }
    }
    
    init(any: AnyConsumer) throws {
        guard any.matches(argumentType: Argument.self) else {
            throw Error.argumentTypeMismatch
        }
        self._accept = { any.acceptAnArgument($0) }
    }
}
public extension SomeConsumer {
    func accept(_ argument: Argument) {
        self._accept(argument)
    }
}

public extension SomeConsumer {
    enum Error: Int, Swift.Error, Equatable {
        case argumentTypeMismatch
    }
}

public struct AnyConsumer: BaseConsumer {
    private let _argumentType: () -> Any.Type
    private let _matchesType: (Any.Type) -> Bool
    private let _accept: (Any) -> Void
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: Consumer {
        self._argumentType = { Concrete.Argument.self }
        self._matchesType = { return $0 == Concrete.Argument.self }
        self._accept = {
            let argument = castOrKill(instance: $0, toType: Concrete.Argument.self)
            concrete.accept(argument)
        }
    }
}

public extension AnyConsumer {
    
    func acceptAnArgument(_ anArgument: Any) {
        self._accept(anArgument)
    }
    
    func matches<Argument>(argumentType: Argument.Type) -> Bool {
        return _matchesType(argumentType)
    }
    
    var argumentType: Any.Type {
        return _argumentType()
    }
}
