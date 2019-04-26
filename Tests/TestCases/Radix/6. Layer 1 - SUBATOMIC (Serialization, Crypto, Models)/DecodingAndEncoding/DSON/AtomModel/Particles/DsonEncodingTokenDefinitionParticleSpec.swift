//
//  DsonEncodingTokenDefinitionParticleSpec.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-13.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest


class DsonEncodingTokenDefinitionParticleTests: XCTestCase {

    func testDsonEncodingOfTokenDefinitionParticle() {
        
        let tokenDefinitionParticle = TokenDefinitionParticle(
            symbol: "POW",
            name: "Proof of Work",
            description: "Radix POW",
            address: "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor",
            granularity: 1,
            permissions: [.burn: .none, .mint: .tokenCreationOnly]
        )
        
        guard let dsonHex = dsonHexStringOrFail(tokenDefinitionParticle) else { return }
        XCTAssertFalse(dsonHex.isEmpty)
    }
    
}
