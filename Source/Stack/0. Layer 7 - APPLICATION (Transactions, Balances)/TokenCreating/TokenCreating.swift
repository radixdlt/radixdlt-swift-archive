//
//  TokenCreating.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol TokenCreating {
    
    var addressOfActiveAccount: Address { get }
    
    /// Creates a new kind of Token
    func create(token: CreateTokenAction) -> ResultOfUserAction
    
    func observeMyTokenDefinitions() -> Observable<TokenDefinitionsState>
}

public extension TokenCreating {
    
    func createToken(
        name: Name,
        symbol: Symbol,
        description: Description,
        supply initialSupplyType: CreateTokenAction.InitialSupply,
        granularity: Granularity = .default
        ) throws -> (result: ResultOfUserAction, rri: ResourceIdentifier) {
        
        let createTokenAction = try CreateTokenAction(
            creator: addressOfActiveAccount,
            name: name,
            symbol: symbol,
            description: description,
            supply: initialSupplyType,
            granularity: granularity
        )
        
        return (create(token: createTokenAction), createTokenAction.identifier)
    }
}
