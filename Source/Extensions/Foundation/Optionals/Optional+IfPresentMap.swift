//
//  Optional+IfPresentMap.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-03.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol EmptyRepresentable {
    static var emptyRepresentation: Self { get }
}

extension String: EmptyRepresentable {
    public static var emptyRepresentation: String { return "" }
}

extension Optional {
    
    var isPresent: Bool {
        return self != nil
    }
    
    func ifPresent<MappedValue>(elseDefaultTo defaultValue: MappedValue, ifPresentDo map: (Wrapped) -> MappedValue) -> MappedValue {
        guard let wrapped = self else {
            return defaultValue
        }
        return map(wrapped)
    }
    
    func ifPresent<MappedValue>(ifPresentDo map: (Wrapped) -> MappedValue) -> MappedValue where MappedValue: EmptyRepresentable {
        return ifPresent(elseDefaultTo: MappedValue.emptyRepresentation, ifPresentDo: map)
    }
}
