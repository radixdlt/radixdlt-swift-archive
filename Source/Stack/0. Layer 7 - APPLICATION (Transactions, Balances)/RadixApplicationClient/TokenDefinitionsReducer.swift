//
//  TokenDefinitionsReducer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public final class TokenDefinitionsReducer: ParticleReducer {}
public extension TokenDefinitionsReducer {
    typealias State = TokenDefinitionsState
    var initialState: TokenDefinitionsState {
        return TokenDefinitionsState()
    }
    
    func reduce(state: State, particle: ParticleConvertible) -> State {
        implementMe()
    }
    func combine(state lhs: State, withOther rhs: State) -> State {
        implementMe()
    }
}
