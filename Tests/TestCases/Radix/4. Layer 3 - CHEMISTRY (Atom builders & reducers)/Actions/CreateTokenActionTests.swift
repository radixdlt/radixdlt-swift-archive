//
//  CreateTokenActionTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-06-06.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK


class CreateTokenActionTests: XCTestCase {
    
    func testAssertThatInitialSupplyMustMatchGranularity() {
        
        func createGran3(initialSupply: NonNegativeAmount) throws -> CreateTokenAction {
            return try createAction(supply: .mutable(initial: initialSupply), granularity: 3)
        }
        
        func assertThrows(initialSupply: NonNegativeAmount) {
            XCTAssertThrowsSpecificError(
                try createGran3(initialSupply: initialSupply),
                CreateTokenAction.Error.initialSupplyNotMultipleOfGranularity
            )
        }
        
        func assertNoThrow(initialSupply: NonNegativeAmount) {
            XCTAssertNoThrow(try createGran3(initialSupply: initialSupply))
        }
        
        assertThrows(initialSupply: 2)
        assertNoThrow(initialSupply: 3)
        assertThrows(initialSupply: 4)
        assertThrows(initialSupply: 5)
        assertNoThrow(initialSupply: 6)
        assertNoThrow(initialSupply: 9)
        assertNoThrow(initialSupply: 300)
        assertThrows(initialSupply: 299)
        assertThrows(initialSupply: 301)
        
    }
}

private extension CreateTokenActionTests {
    
    func createAction(
        supply: CreateTokenAction.InitialSupply,
        granularity: Granularity = .default
    ) throws -> CreateTokenAction {
        return try CreateTokenAction(
            creator: .irrelevant,
            name: .irrelevant,
            symbol: .irrelevant,
            description: .irrelevant,
            supply: supply,
            granularity: granularity
        )
    }
    
}

// MARK: - IRRELEVANT For this test
private extension Address {
    static var irrelevant: Address {
        return Address(magic: .irrelevant, publicKey: .irrelevant)
    }
}

private extension PublicKey {
    static var irrelevant: PublicKey {
        return PublicKey(private: PrivateKey())
    }
}


private extension Magic {
    static var irrelevant: Magic {
        return 1
    }
}

private extension String {
    static var irrelevant: String {
        return "irrelevant"
    }
}

private extension Symbol {
    static var irrelevant: Symbol {
        return "IRR"
    }
}

private extension Name {
    static var irrelevant: Name {
        return "Irrelevant"
    }
}

private extension Description {
    static var irrelevant: Description {
        return "Irrelevant description"
    }
}
