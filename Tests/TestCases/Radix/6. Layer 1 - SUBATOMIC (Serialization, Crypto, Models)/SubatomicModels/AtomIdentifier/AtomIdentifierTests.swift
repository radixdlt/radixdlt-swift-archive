//
//  AtomIdentifierTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-05-24.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK

class AtomIdentifierTests: XCTestCase {
    
    let alice = RadixIdentity(privateKey: 1)
    let bob = RadixIdentity(privateKey: 2)
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        
        XCTAssertEqual(alice.address, "JF5FTU5wdsKNp4qcuFJ1aD9enPQMocJLCqvHE2ZPDjUNag8MKun")
        XCTAssertEqual(alice.address.hashId, "b1cd0a4eb6d1cea5eb288fb4474ac403")
        XCTAssertEqual(alice.shard, -5634836225579692379)
        
        XCTAssertEqual(bob.address, "JFeqmatdMyjxNce38w3pEfDeJ9CV6NCkygDt3kXtivHLsP3p846")
        XCTAssertEqual(bob.address.hashId, "e142e5bb89503e3210b1f2c893eb5c12")
        XCTAssertEqual(bob.shard, -2214955473087480270)
    }
    
    func testTwoShards() {
        let expectedShard: Shard = 2
        testAid(shards: [1, expectedShard], firstByteInHash: 3, expectedShard: expectedShard)
    }
    
    func testMixedNegative() {
        
        func doTest(
            firstByteInHash: Byte,
            shards: Shards,
            whenSorted expectedSorted: [Shard],
            expected: Shard
        ) {
            let sorted: [Shard] = shards.asSet.sorted(by: Shard.areInIncreasingOrderUnsigned)
            XCTAssertEqual(sorted, expectedSorted)
            testAid(shards: shards, firstByteInHash: firstByteInHash, expectedShard: expected)
        }
        
        doTest(
            firstByteInHash: 5,
            shards: [9, -7, 5],
            whenSorted: [5, 9, -7],
            expected: -7 // 5 % 3 => index 2 => -7
        )
        
        doTest(
            firstByteInHash: 6,
            shards: [9, -7, 5],
            whenSorted: [5, 9, -7],
            expected: 5 // 6 % 3 => index 0 => 5
        )
        
        doTest(
            firstByteInHash: 7,
            shards: [9, -7, 5],
            whenSorted: [5, 9, -7],
            expected: 9 // 7 % 3 => index 1 => 9
        )
        
        doTest(
            firstByteInHash: 9,
            shards: [-9, -7, -13, 5],
            whenSorted: [5, -13, -9, -7],
            expected: -13 // 9 % 4 => index 1 => -13
        )
    }
    
    func testOneShardManyHashes() {
        let expectedShard: Shard = 1
        for firstByteInt in 0...255 {
            let firstByte = Byte(firstByteInt)
            testAid(shards: [expectedShard], firstByteInHash: firstByte, expectedShard: expectedShard)
        }
    }
    
    func testAtomIdentifierForAtomFromCreateTokenAction() {
        
        let createTokenAction = try! CreateTokenAction(
            creator: alice.address,
            name: "Test",
            symbol: "TEST",
            description: "Test description",
            supply: .fixed(to: 10)
        )
        
        let createTokenAtom = testAidOfAtomFrom(
            action: createTokenAction,
            mapper: DefaultCreateTokenActionToParticleGroupsMapper(),
            expectedAidShard: .this(alice.shard)
        )
        
        let rri = createTokenAction.identifier
        
        let transferTokens = TransferTokenAction(from: alice, to: bob, amount: 10, tokenResourceIdentifier: rri)
        
        let consumables = createTokenAtom.spunParticles().compactMap { $0.mapToSpunParticle(with: TransferrableTokensParticle.self) }
        XCTAssertEqual(consumables.count, 1)
        let startBalance = TokenBalance(spunTransferrable: consumables[0])
        
        let atomFromTransfer = testAidOfAtomFrom(
            action: transferTokens,
            mapper: StatefulTransferTokensParticleGroupMapper(currentBalance: startBalance),
            expectedAidShard: .eitherIn([alice.shard, bob.shard])
        )
        XCTAssertEqual(try! atomFromTransfer.shards(), [alice.shard, bob.shard])
    }
}

private enum ShardAssertion {
    case this(Shard)
    case eitherIn(Shards)
    
    func assert(actual: Shard) -> Bool {
        switch self {
        case .this(let singleShard): return singleShard == actual
        case .eitherIn(let shards): return shards.contains(actual)
        }
    }
}

struct StatefulTransferTokensParticleGroupMapper: StatelessActionToParticleGroupsMapper, TransferTokenActionToParticleGroupsMapper {
    
    private let currentBalance: TokenBalance
    
    init(currentBalance: TokenBalance) {
        self.currentBalance = currentBalance
    }
    
    func particleGroups(for action: Action) -> ParticleGroups {
        return try! particleGroups(for: action, currentBalance: self.currentBalance)
    }
}

private extension AtomIdentifierTests {
    @discardableResult
    func testAidOfAtomFrom<Action, Mapper>(
        action: Action,
        mapper: Mapper,
        expectedAidShard: ShardAssertion
        ) -> Atom
        where Mapper: StatelessActionToParticleGroupsMapper,
        Action == Mapper.Action
    {
        
        let particleGroup = mapper.particleGroups(for: action)
        
        let date = TimeConverter.dateFrom(millisecondsSince1970: 237)
        let metaData = ChronoMetaData.timestamp(date)
        
        let atom = Atom(
            metaData: metaData,
            particleGroups: particleGroup
        )
        
        let aid = atom.identifier()
        
        XCTAssertTrue(expectedAidShard.assert(actual: aid.shard), "Actual shard not found in expected, actual: \(aid.shard)")
        
        return atom
    }
}


private let magic: Magic = 63799298
private extension RadixIdentity {
    init() {
        self.init(magic: magic)
    }
    
    init(privateKey: PrivateKey) {
        self.init(private: privateKey, magic: magic)
    }
}


private extension AtomIdentifierTests {
    func testAid(shards: Shards, firstByteInHash firstByte: Byte, expectedShard: Shard) {
        let mockedHash = RadixHash(unhashedData: unsafe︕！GenerateBytes(count: 32, replacingFirstWith: firstByte), hashedBy: SkipHashing())
        XCTAssertEqual(mockedHash.asData[0], firstByte)
        
        do {
            let aid = try AtomIdentifier(hash: mockedHash, shards: shards)
            
            XCTAssertEqual(
                aid.shard,
                expectedShard,
                "Expected shard: \(expectedShard), but got: \(aid.shard), given first byte in hash: \(firstByte), byte % shard.size: \(Int(firstByte) % shards.count)"
            )
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

func unsafe︕！GenerateBytes(count: Int, replacingFirstWith replacementByte: Byte? = nil) -> Data {
    do {
        var random = try securelyGenerateBytes(count: count)
        if let replacementByte = replacementByte, count > 0 {
            random[0] = replacementByte
        }
        return random
    } catch {
        incorrectImplementation("Unable to generate bytes, error: \(error)")
    }
}

func generateShardSet(numberOfShards: Int) -> Shards {
    var randomSet = Set<Shard>()
    while randomSet.count != numberOfShards {
        randomSet.insert(Shard.random())
    }
    return try! Shards(set: randomSet)
}

protocol Randomizing {
    static func random() -> Self
}

extension Int64: Randomizing {
    static func random() -> Int64 {
        return Int64.random(in: Int64.min...Int64.max)
    }
}
