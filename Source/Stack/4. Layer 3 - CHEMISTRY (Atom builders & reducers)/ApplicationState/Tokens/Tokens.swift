//
//  TokenDefintionState.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public final class Tokens: TokensDefinitionsStore {
    private var tokens = [ResourceIdentifier: Token]()
    public init() {}
}

public extension Tokens {
    func add(token: Token, resourceIdentifier: ResourceIdentifier) {
        tokens[resourceIdentifier] = token
    }
    
    func token(for identifier: ResourceIdentifier) -> Token? {
        guard let token = tokens[identifier] else {
            return nil
        }
        return token
    }
}
