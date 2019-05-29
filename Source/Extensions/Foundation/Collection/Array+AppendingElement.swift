//
//  Array+AppendingElement.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Array {
    static func += (array: inout Array, newElement: Element) {
        array.append(newElement)
    }
    
    static func + (array: [Element], element: Element) -> [Element] {
        var mutable = array
        mutable.append(element)
        return mutable
    }
    
    static func + (element: Element, array: [Element]) -> [Element] {
        var mutable = [element]
        mutable.append(contentsOf: array)
        return mutable
    }
}
