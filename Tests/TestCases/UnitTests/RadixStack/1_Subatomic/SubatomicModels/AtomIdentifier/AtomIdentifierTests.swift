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

import XCTest
@testable import RadixSDK

class AtomIdentifierTests: TestCase {
    
    let alice = Address(privateKey: 1)
    let bob = Address(privateKey: 2)
    
    override func setUp() {
        super.setUp()
        
        XCTAssertEqual(alice, "JF5FTU5wdsKNp4qcuFJ1aD9enPQMocJLCqvHE2ZPDjUNag8MKun")
        XCTAssertEqual(alice.hashEUID, "b1cd0a4eb6d1cea5eb288fb4474ac403")
        XCTAssertEqual(alice.shard, -5634836225579692379)
        
        XCTAssertEqual(bob, "JFeqmatdMyjxNce38w3pEfDeJ9CV6NCkygDt3kXtivHLsP3p846")
        XCTAssertEqual(bob.hashEUID, "e142e5bb89503e3210b1f2c893eb5c12")
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
    
    func testEndianessNegativeShards() throws {
        let aidString: String = "126fd230a7cab9d9766f1065d498c4ac80ad2b754af1889fb1cd0a4eb6d1cea5"
        let aidFromString = AtomIdentifier(stringLiteral: aidString)
        let shard: Shard = -5634836225579692379
        XCTAssertEqual(aidFromString.shard, shard)
        XCTAssertEqual(aidString, aidFromString.hex)
        let aidFromHashAndShard = try AtomIdentifier(hash: "126fd230a7cab9d9766f1065d498c4ac80ad2b754af1889fdafeb316d52c54e0", shard: shard)
        XCTAssertEqual(aidFromHashAndShard, aidFromString)
    }
    
    func testAtomIdentifierForAtomFromCreateTokenAction() throws {
        
        let createTokenAction = try CreateTokenAction(
            creator: alice.address,
            name: "Test",
            symbol: "TEST",
            description: "Test description",
            supply: .fixed(to: 10)
        )
        
        let createTokenAtom = try doTestAidOfAtomFrom(
            action: createTokenAction,
            mapper: DefaultCreateTokenActionToParticleGroupsMapper(),
            expectedAidShard: .this(alice.shard)
        )
        
        let rri = createTokenAction.identifier
        
        let transferTokens = TransferTokensAction(from: alice, to: bob, amount: 10, tokenResourceIdentifier: rri)
        
        let consumables = createTokenAtom.transferrableTokensParticles(spin: .up)
        
        XCTAssertEqual(consumables.count, 1)
     
        let mutableSupplyTokenDefinitionParticles = createTokenAtom.mutableSupplyTokenDefinitionParticles(spin: .up)
      
        let fixedSupplyTokenDefinitionParticles = createTokenAtom.fixedSupplyTokenDefinitionParticles(spin: .up)
        
        XCTAssertEqual((mutableSupplyTokenDefinitionParticles.count + fixedSupplyTokenDefinitionParticles.count), 1)
        
        var upParticles: [AnyUpParticle] = [AnyUpParticle(particle: consumables[0])]
        
        if let fixed = fixedSupplyTokenDefinitionParticles.first {
            upParticles.append(AnyUpParticle(particle: fixed))
        }
        
        if let mutable = mutableSupplyTokenDefinitionParticles.first {
            upParticles.append(AnyUpParticle(particle: mutable))
        }
        
        let atomFromTransfer = try doTestAidOfAtomFrom(
            action: transferTokens,
            mapper: DefaultTransferTokensActionToParticleGroupsMapper(),
            upParticles: upParticles,
            expectedAidShard: .eitherIn([alice.shard, bob.shard])
        )
        XCTAssertEqual(try atomFromTransfer.shards(), [alice.shard, bob.shard])
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

private extension AtomIdentifierTests {
    @discardableResult
    func doTestAidOfAtomFrom<Action, Mapper>(
        action: Action,
        mapper: Mapper,
        upParticles: [AnyUpParticle] = [],
        expectedAidShard: ShardAssertion
    ) throws -> Atom
        where Mapper: StatefulActionToParticleGroupsMapper,
        Action == Mapper.Action
    {
        
        let particleGroup = try mapper.particleGroups(for: action, upParticles: upParticles, addressOfActiveAccount: alice)
        
        let date = TimeConverter.dateFrom(millisecondsSince1970: 237)
        let metaData = ChronoMetaData.timestamp(date)
        
        let atom = Atom(
            metaData: metaData,
            particleGroups: particleGroup
        )
        
        let aid = atom.identifier()
        print(aid.stringValue)
        XCTAssertTrue(expectedAidShard.assert(actual: aid.shard), "Actual shard not found in expected, actual: \(aid.shard)")
        
        return atom
    }
}


private let magic: Magic = 63799298
extension Address {
    init() {
        self.init(privateKey: PrivateKey())
    }

    init(privateKey: PrivateKey) {
        let publicKey = PublicKey(private: privateKey)
        self.init(magic: magic, publicKey: publicKey)
    }
    
    init(magic newMagic: Magic, privateKey: PrivateKey) {
        let publicKey = PublicKey(private: privateKey)
        self.init(magic: newMagic, publicKey: publicKey)
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
