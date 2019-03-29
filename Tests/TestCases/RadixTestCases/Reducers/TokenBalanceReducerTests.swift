//
//  TokenBalanceReducerTests.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest

public enum SpinTransition {
    case neutralToUp
    case upToDown
    case revertDownToUp
    case revertUpToNeutral
    
    var spinTo: Spin {
        switch self {
        case .neutralToUp: return .up
        case .upToDown: return .down
        case .revertDownToUp: return .up
        case .revertUpToNeutral: return .neutral
        }
    }
}



public struct TransitionedParticle {
    let particle: ParticleConvertible
    let spinTransition: SpinTransition
    
    var spinTo: Spin {
       return spinTransition.spinTo
    }
}

public extension TransitionedParticle {
    static func neutralToUp(particle: ParticleConvertible) -> TransitionedParticle {
        return TransitionedParticle(particle: particle, spinTransition: .neutralToUp)
    }
    
    static func upToDown(particle: ParticleConvertible) -> TransitionedParticle {
        return TransitionedParticle(particle: particle, spinTransition: .upToDown)
    }
    
    static func revertDownToUp(particle: ParticleConvertible) -> TransitionedParticle {
        return TransitionedParticle(particle: particle, spinTransition: .revertDownToUp)
    }
    
    static func revertUpToNeutral(particle: ParticleConvertible) -> TransitionedParticle {
        return TransitionedParticle(particle: particle, spinTransition: .revertUpToNeutral)
    }
}

public struct TokenBalanceReducer {
    func reduce(
        balances: TokenBalances = [:],
        transitionedParticle: TransitionedParticle
    ) -> TokenBalances {
        guard let consumable = transitionedParticle.particle as? ConsumableTokens else {
            return balances
        }
        return balances.adding(consumable: consumable, spin: transitionedParticle.spinTo)
    }
}

class TokenBalanceReducerTests: XCTestCase {
    func testSimpleBalance() {
        let token = TokenDefinitionReference(address: "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei", symbol: "XRD")
        
        let minted = MintedTokenParticle(
            address: "JHdWTe8zD2BMWwMWZxcKAFx1E8kK3UqBSsqxD9UWkkVD78uMCei",
            amount: 10,
            tokenDefinitionReference: token
        )
     
        let reducer = TokenBalanceReducer()
        let balances = reducer.reduce(transitionedParticle: TransitionedParticle.neutralToUp(particle: minted))
        let balance = balances[token]
        XCTAssertEqual(balance?.amount.signedAmount, 10)
    }
}
