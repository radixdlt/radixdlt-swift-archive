//
//  Bool_Extensions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-03.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Bool {
    
    func ifTrue<MappedValue>(
        doMap map: () -> MappedValue
        ) -> MappedValue where MappedValue: EmptyRepresentable {
        return ifTrue(elseDefaultTo: MappedValue.emptyRepresentation, doMap: map)
    }
    
    func ifTrue<MappedValue>(
        elseDefaultTo defaultValue: MappedValue,
        doMap map: () -> MappedValue
        ) -> MappedValue {
        return ifEquals(expectedValue: true, elseDefaultTo: defaultValue, doMap: map)
    }
    
    func ifFalse<MappedValue>(
        elseDefaultTo defaultValue: MappedValue,
        doMap map: () -> MappedValue
        ) -> MappedValue {
        return ifEquals(expectedValue: false, elseDefaultTo: defaultValue, doMap: map)
    }
}

private extension Bool {
    
    func ifEquals<MappedValue>(
        expectedValue: Bool,
        elseDefaultTo defaultValue: MappedValue,
        doMap map: () -> MappedValue
        ) -> MappedValue {
        
        guard self == expectedValue else { return defaultValue }
        return map()
    }
}
