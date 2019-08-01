//
//  Function.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-02.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct Function<Argument, Return> {
    
    private let _apply: (Argument) -> Return
    
    public init(_ apply: @escaping (Argument) -> Return) {
        self._apply = apply
    }
}

public extension Function {
    func apply(_ argument: Argument) -> Return {
        return self._apply(argument)
    }
}

public struct BiFunction<Argument0, Argument1, Return> {
    
    private let _apply: (Argument0, Argument1) -> Return
    
    public init(_ apply: @escaping (Argument0, Argument1) -> Return) {
        self._apply = apply
    }
}

public extension BiFunction {
    func apply(_ argument0: Argument0, _ argument1: Argument1) -> Return {
        return self._apply(argument0, argument1)
    }
}
