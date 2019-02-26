//
//  Fungible+Sequence.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-02-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension Sequence where Element: Fungible {
    
    func filter<F>(type: TokenType) -> [F] where F: Fungible {
        return filter(type: type)
            .compactMap { $0 as? F }
    }
    
    func filter(type: TokenType) -> [Fungible] {
        return filter { $0.type == type }
    }
}
