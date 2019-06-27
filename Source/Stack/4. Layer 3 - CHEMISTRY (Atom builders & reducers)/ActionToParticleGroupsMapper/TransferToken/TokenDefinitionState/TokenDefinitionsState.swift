//
//  TokenDefinitionsState.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct TokenDefinitionsState: ApplicationState {
    private var tokenDefinitions: [ResourceIdentifier: TokenDefinition] = [:]
}

public extension TokenDefinitionsState {
    func tokenDefinition(identifier: ResourceIdentifier) -> TokenDefinition? {
        return tokenDefinitions[identifier]
    }
}
