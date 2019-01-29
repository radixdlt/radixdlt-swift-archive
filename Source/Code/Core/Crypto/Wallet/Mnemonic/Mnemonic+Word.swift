//
//  Mnemonic+Word.swift
//  RadixSDK
//
//  Created by Alexander Cyon on 2019-01-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Mnemonic {
    public struct Word {
        public let value: String
        
        public init(value: String) {
            precondition(!value.isEmpty)
            self.value = value
        }
    }
}

extension Mnemonic.Word: ExpressibleByStringLiteral {}
public extension Mnemonic.Word {
    init(stringLiteral value: String) {
        self.init(value: value)
    }
}
