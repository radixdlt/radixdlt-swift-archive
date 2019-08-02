//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
//

import Foundation
import XCTest
@testable import RadixSDK

class CreateTokenActionToParticleGroupsMapperTests: XCTestCase {

    private let magic: Magic = 63799298
    private lazy var account = Account(privateKey: 1)
    private lazy var address = Address(magic: magic, publicKey: account.publicKey)
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    func testMutableSupplyTokenCreationWithoutInitialSupply() {
//
//        let createTokenAction = try! CreateTokenAction(
//            creator: address,
//            name: "Cyon",
//            symbol: "CCC",
//            description: "Cyon Crypto Coin is the worst shit coin",
//            supply: .mutable(initial: 0)
//        )
//
//        let particleGroups = DefaultCreateTokenActionToParticleGroupsMapper().particleGroups(for: createTokenAction)
//        XCTAssertEqual(particleGroups.count, 1)
//        guard let group = particleGroups.first else { return }
//
//        assertCorrectnessTokenCreationGroup(group, testPermissions: false)
        
        doTestTokenCreation(initialSupply: .mutable(initial: 0))
    }
    
    func testTokenCreationWithInitialSupplyPartial() {
        doTestTokenCreation(initialSupply: .fixed(to: 1000))
    }
    
    func testTokenCreationWithInitialSupplyAll() {
//        doTestTokenCreation(initialSupply: try! PositiveAmount(nonNegative: Supply.maxAmountValue))
        doTestTokenCreation(initialSupply: .fixed(to: try! PositiveAmount(nonNegative: Supply.maxAmountValue)))
    }
    
    func testAssertMaxSupplySubtractedFromMaxIsNil() {
        XCTAssertNil(Supply.max.subtractedFromMax)
    }
    
    func testAssert100SubtractedFromMaxSupplyIsCorrectValue() {
        let hundred: Supply = 100
        XCTAssertAllEqual(
            hundred.subtractedFromMax,
            try? Supply(subtractingFromMax: hundred.amount),
            try? Supply(nonNegativeAmount: Supply.maxAmountValue - hundred.amount)
        )
    }
}

private extension CreateTokenActionToParticleGroupsMapperTests {
    func doTestTokenCreation(initialSupply: CreateTokenAction.InitialSupply) {
        let createTokenAction = try! CreateTokenAction(
            creator: address,
            name: "Cyon",
            symbol: "CCC",
            description: "Cyon Crypto Coin is the worst shit coin",
            supply: initialSupply
        )
        
        let particleGroups = DefaultCreateTokenActionToParticleGroupsMapper().particleGroups(for: createTokenAction)
        guard let tokenCreationGroup = particleGroups.first else { return }
        assertCorrectnessTokenCreationGroup(tokenCreationGroup, testPermissions: initialSupply.isFixed)
        
    
        
        switch initialSupply {
        case .fixed: break
        case .mutable(let maybeInitial):
            guard let mutableInitialSupply = maybeInitial,
                mutableInitialSupply.amount > 0 else { return }
            
            XCTAssertEqual(particleGroups.count, 2)
            let mintTokenGroup = particleGroups[1]
            
            assertCorrectnessMintTokenGroup(
                mintTokenGroup,
                tokenCreationGroup: tokenCreationGroup,
                initialSupply: mutableInitialSupply.positiveAmount!,
                createTokenAction: createTokenAction
            )
        }
        
     
    }
    
    func assertCorrectnessMintTokenGroup(
        _ mintTokenGroup: ParticleGroup,
        tokenCreationGroup: ParticleGroup,
        initialSupply initialSupplyAmount: PositiveAmount,
        createTokenAction: CreateTokenAction
        ) {
        
        guard
            case let tokenCreationGroupParticles = tokenCreationGroup.spunParticles,
            tokenCreationGroupParticles.count == 3,
            let unallocatedParticleFromTokenCreationGroup = tokenCreationGroupParticles[2].particle as? UnallocatedTokensParticle else {
                return XCTFail("Expected UnallocatedTokensParticle at index 2 in ParticleGroup at index 0")
        }
        
        let initialSupply = try! Supply(positiveAmount: initialSupplyAmount)
        
        let expectUnallocatedFromLeftOverSupply: Bool
        if let leftOverSupply = initialSupply.subtractedFromMax {
            expectUnallocatedFromLeftOverSupply = leftOverSupply.amount >= 1
        } else {
            expectUnallocatedFromLeftOverSupply = false
        }
        
        let spunParticles = mintTokenGroup.spunParticles
        
        if expectUnallocatedFromLeftOverSupply {
            XCTAssertEqual(spunParticles.count, 3)
        } else {
            XCTAssertEqual(spunParticles.count, 2)
        }
        
        guard
            let spunUnallocatedTokensParticle = spunParticles[0].mapToSpunParticle(with: UnallocatedTokensParticle.self),
            let spunTransferrableTokensParticle = spunParticles[1].mapToSpunParticle(with: TransferrableTokensParticle.self)
            else { return }
        XCTAssertEqual(spunUnallocatedTokensParticle.spin, .down)
        XCTAssertEqual(spunTransferrableTokensParticle.spin, .up)
        
        let unallocatedTokensParticle = spunUnallocatedTokensParticle.particle
        let transferrableTokensParticle = spunTransferrableTokensParticle.particle
        
        XCTAssertEqual(
            unallocatedParticleFromTokenCreationGroup.hashEUID,
            unallocatedTokensParticle.hashEUID,
            "The `UnallocatedTokensParticle` in the two ParticleGroups should be the same, but with different spin"
        )
        
        XCTAssertEqual(
            transferrableTokensParticle.amount.abs,
            createTokenAction.initialSupply.amount
        )
        
        if expectUnallocatedFromLeftOverSupply {
            guard
                let spunLeftOverUnallocatedTokensParticle = spunParticles[2].mapToSpunParticle(with: UnallocatedTokensParticle.self)
                else { return }
            
            XCTAssertEqual(spunLeftOverUnallocatedTokensParticle.spin, .up)
            let leftOverUnallocatedTokensParticle = spunLeftOverUnallocatedTokensParticle.particle
            XCTAssertEqual(unallocatedTokensParticle.tokenDefinitionReference, leftOverUnallocatedTokensParticle.tokenDefinitionReference)
        }
    }
    
    
    func assertCorrectnessTokenCreationGroup(_ group: ParticleGroup, testPermissions: Bool) {
        let spunParticles = group.spunParticles
        XCTAssertEqual(spunParticles.count, 3)
        guard
            let spunRriParticle = spunParticles[0].mapToSpunParticle(with: ResourceIdentifierParticle.self),
            let spunTokenDefinitionParticle = spunParticles[1].mapToSpunParticle(with: MutableSupplyTokenDefinitionParticle.self),
            let spunUnallocatedTokensParticle = spunParticles[2].mapToSpunParticle(with: UnallocatedTokensParticle.self)
            else { return }
        XCTAssertEqual(spunRriParticle.spin, .down)
        XCTAssertEqual(spunTokenDefinitionParticle.spin, .up)
        XCTAssertEqual(spunUnallocatedTokensParticle.spin, .up)
        let rriParticle = spunRriParticle.particle
        let tokenDefinitionParticle = spunTokenDefinitionParticle.particle
        let unallocatedTokensParticle = spunUnallocatedTokensParticle.particle
        
        
        XCTAssertAllEqual(
            "/JF5FTU5wdsKNp4qcuFJ1aD9enPQMocJLCqvHE2ZPDjUNag8MKun/CCC",
            rriParticle.resourceIdentifier,
            tokenDefinitionParticle.tokenDefinitionReference,
            unallocatedTokensParticle.tokenDefinitionReference
        )
        
        XCTAssertAllEqual(
            1,
            tokenDefinitionParticle.granularity,
            unallocatedTokensParticle.granularity
        )
        
        if testPermissions {
            XCTAssertAllEqual(
                [.mint: .tokenOwnerOnly, .burn: .none],
                tokenDefinitionParticle.permissions,
                unallocatedTokensParticle.permissions
            )
        }
        
        XCTAssertEqual(
            unallocatedTokensParticle.amount,
            Supply.max
        )
    }
}
