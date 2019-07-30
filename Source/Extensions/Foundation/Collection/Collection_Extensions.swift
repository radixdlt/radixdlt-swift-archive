//
//  Collection_Extensions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

internal enum ZeroOneTwoAndMany<Element> {
    case zero
    case one(single: Element)
    case two(first: Element, secondAndLast: Element)
    case many(first: Element, second: Element, last: Element)
}

internal extension Collection {
    
    var countedElementsZeroOneTwoAndMany: ZeroOneTwoAndMany<Element> {
        if isEmpty {
            return .zero
        } else {
            let firstElement = first!
            if count == 1 {
                return .one(single: firstElement)
            } else {
                let second = self.dropFirst().first!
                if count == 2 {
                    return .two(first: firstElement, secondAndLast: second)
                } else {
                    let last = self.suffix(1).first!
                    return .many(first: firstElement, second: second, last: last)
                }
            }
            
        }
    }
}
