//
//  TokensDefinitionsStore.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-07.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol TokensDefinitionsStore {
    func add(token: Token, resourceIdentifier: ResourceIdentifier)
    func token(for identifier: ResourceIdentifier) -> Token?
}

public extension TokensDefinitionsStore {
    
    func add(tokenConvertible: TokenConvertible, resourceIdentifier: ResourceIdentifier) {
        let token = Token(tokenConvertible: tokenConvertible)
        add(token: token, resourceIdentifier: resourceIdentifier)
    }
    
    func add(tokenDefinitionParticle: TokenDefinitionParticle, resourceIdentifier: ResourceIdentifier) {
        add(tokenConvertible: tokenDefinitionParticle, resourceIdentifier: resourceIdentifier)
    }
}
