import XCTest
@testable import RadixSDK

final class GenerateTestVectorsForLedgerApp: TestCase {
 
    private var mapper: TransactionToAtomMapper!
    
    private let magic: Magic = 1
    
    private lazy var alicePrivateKey: PrivateKey = {
        try! PrivateKey(string: LedgerSignAtomTestVector.hardCodedPrivateKeyAlice)
    }()
    
    private lazy var alice: Address = {
        Address(magic: magic, privateKey: alicePrivateKey)
    }()
    
    private lazy var bob: Address = {
        Address(magic: magic, publicKey: .irrelevant)
    }()
    
    private lazy var clara: Address = {
        Address(magic: magic, publicKey: .irrelevant)
    }()
    
    private lazy var diana: Address = {
        Address(magic: magic, publicKey: .irrelevant)
    }()
    
    override func setUp() {
        super.setUp()
        XCTAssertAllInequal(alice, bob, clara, diana)
        print("🙋🏼‍♀️ Alice: \(alice)")
        print("🙋🏻 Bob:   \(bob)")
        print("🙋🏻‍♀️ Clara: \(clara)")
        print("🙋🏾‍♀️ Diana: \(diana)")
        
        (mapper, token) = mapperWithToken()
    }
    

    private let jsonEncoder: JSONEncoder = RadixJSONEncoder(outputFormat: [.prettyPrinted, .withoutEscapingSlashes])
    
    private let testCasePrefix = "testMakeVector_"
    
    private var token: TokenConvertible!
    private var rri: ResourceIdentifier { token.tokenDefinitionReference }
    private var allTokens: PositiveAmount {
        guard let supply = token.supply else { fatalError("Expected supply") }
        guard let positiveSupply = try? PositiveSupply(related: supply) else {
            fatalError("Expected non zero supply")
        }
        return positiveSupply.amount
        
    }
}

// MARK: Vector Generation
// ==================
// ==================
// ==================
extension GenerateTestVectorsForLedgerApp {
    
    // MARK: *** NO DATA ***
    // ==================
    // ==================
    // ==================
    
    // MARK: Single Transfer
    // ==================
    // ==================
    // ==================
    
    // MARK: Small Amount
    // ==================
    // ==================
    // ==================
    func testMakeVector_no_data_single_transfer_small_amount_with_change() {
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: 9, to: bob)
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_no_data_single_transfer_small_amount_no_change() {
        let smallSupply: PositiveSupply = 10
        (mapper, token) = mapperWithToken(supply: .fixed(to: smallSupply))
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: smallSupply.amount, to: bob)
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    // MARK: Huge Amount
    // ==================
    // ==================
    // ==================
    func testMakeVector_no_data_single_transfer_huge_amount_with_change() {
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: PositiveSupply.max.amount - 1337, to: bob)
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_no_data_single_transfer_huge_amount_no_change() {
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: allTokens, to: bob)
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    
    // MARK: *** DATA ***
    // ==================
    // ==================
    // ==================
    // MARK: No Transfers
    func testMakeVector_data_no_transfer_burn_action() {
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Burn(amount: 5)
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_data_no_transfer_message_action() {
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: .irrelevant, actor: alice)) {
                Message(text: "Hey you!", to: clara)
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    
    func testMakeVector_data_no_transfer_put_unique_action() {
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: .irrelevant, actor: alice)) {
                PutUnique("Unicorn")
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    // MARK: Single Transfer
    // ==================
    // ==================
    // ==================
    
    // MARK: Small Amount
    // ==================
    // ==================
    // ==================
    func testMakeVector_data_single_transfer_small_amount_with_change() {
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: 9, to: bob)
                 PutUnique("Unicorn")
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_data_single_transfer_small_amount_no_change() {
        let smallSupply: PositiveSupply = 10
        (mapper, token) = mapperWithToken(supply: .fixed(to: smallSupply))
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Message(text: "Hey you!", to: clara)
                Transfer(amount: smallSupply.amount, to: bob)
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    // MARK: Huge Amount
    // ==================
    // ==================
    // ==================
    func testMakeVector_data_single_transfer_huge_amount_with_change() {
        let bigSupply = Supply.max
        (mapper, token) = mapperWithToken(supply: .mutable(initial: bigSupply))
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: bigSupply.amount - 1337, to: bob)
                Burn(amount: 5)
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_data_single_transfer_huge_amount_no_change() {
        let bigSupply = Supply.max - 1234
        (mapper, token) = mapperWithToken(supply: .mutable(initial: bigSupply))
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: allTokens, to: bob)
                PutUnique("Unicorn")
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    
    func testMakeVector_data_single_transfer_no_change_small_amount_unique_and_message() {
        let smallSupply: PositiveSupply = 10
        (mapper, token) = mapperWithToken(supply: .fixed(to: smallSupply))
        
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                PutUnique("Unicorn")
                Transfer(amount: smallSupply.amount, to: bob)
                Message(text: "Hey you!", to: diana)
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    

    // MARK: Multiple Transfers
    // ==================
    // ==================
    // ==================
    
    func testMakeVector_data_multiple_transfers_small_amounts_with_change_unique() {
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: 9, to: bob)
                Transfer(amount: 42, to: clara)
                Transfer(amount: 237, to: diana)
                PutUnique("Unicorn")
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_data_multiple_transfers_small_and_big_amount_messages() {
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Message(text: "All I ever wanted", to: clara)
                Transfer(amount: 123, to: bob)
                Message(text: "All I ever needed", to: clara)
                Transfer(amount: PositiveAmount.max - 123, to: clara)
                Message(text: "Is you, in my arms", to: clara)
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
}

// MARK: Atom preparation
private extension GenerateTestVectorsForLedgerApp {
    
    func mapperWithToken(
        symbol: Symbol = "ZELDA",
        supply: CreateTokenAction.InitialSupply.SupplyTypeDefinition = .mutable(initial: Supply.max)
    ) -> (TransactionToAtomMapper, TokenConvertible) {
        
        let createTokenAction = try! CreateTokenAction.new(
            creator: alice,
            symbol: symbol,
            supply: supply
        )
        
        return mapperWithToken(createTokenAction)
    }
    
    func mapperWithToken(_ createTokenAction: CreateTokenAction) -> (TransactionToAtomMapper, TokenConvertible) {
        let genesisMapper = IndependentTransactionToAtomMapper()
        let genesisAtom = try! genesisMapper.atomFrom(transaction: Transaction(createTokenAction), addressOfActiveAccount: alice)
        let mapper = DefaultTransactionToAtomMapper(atomStore: InMemoryAtomStore.init(genesisAtoms: [genesisAtom]))
        
        let tokenDefinition = TokenDefinition(createTokenAction: createTokenAction)
        
        return (mapper, tokenDefinition)
    }
    
    func makePretty(_ description: String) -> String {
        precondition(description.starts(with: testCasePrefix))
        return description
            .replacingOccurrences(of: testCasePrefix, with: "")
            .replacingOccurrences(of: "_", with: " ")
            .replacingOccurrences(of: "()", with: "")
    }
    
    
    func makeVectorJSON(
        description nonPrettyDescription: String = #function,
        _ makeTransaction: @autoclosure () -> Transaction,
        appendingAdhocParticleWrappedInSeparateGroups makeParticles: @autoclosure () -> [AnySpunParticle] = []
    ) -> String {
        let description = makePretty(nonPrettyDescription)
        let vector = makeVector(description: description, makeTransaction(), appendingAdhocParticleWrappedInSeparateGroups: makeParticles())
        let jsonData = try! jsonEncoder.encode(vector)
        return String(data: jsonData, encodingForced: .utf8)
    }
    
    func makeVector(
        description: String,
        _ makeTransaction: @autoclosure () -> Transaction,
        appendingAdhocParticleWrappedInSeparateGroups makeParticles: @autoclosure () -> [AnySpunParticle] = []
    ) -> LedgerSignAtomTestVector {
        
        let transaction = makeTransaction()
        
        var atom = try! mapper.atomFrom(transaction: transaction, addressOfActiveAccount: alice)
        
        makeParticles()
            .map({ try! ParticleGroup(spunParticles: $0) })
            .forEach { atom.appendingParticleGroup($0) }
        
        
        return LedgerSignAtomTestVector(description: description, magic: magic, atom: atom, actor: alice)
    }
}

// MARK: Extension/Helpers
extension TokenDefinition {
    init(createTokenAction: CreateTokenAction) {
        self.init(tokenConvertible: createTokenAction)
    }
}

extension PositiveSupply {
    var amount: PositiveAmount {
        PositiveAmount(other: self)
    }
}

extension Supply {
    var amount: PositiveAmount {
        guard let amount = try? PositiveAmount(unrelated: self) else {
            fatalError("Failed to convert supply to PositiveAmount: \(self)")
        }
        return amount
    }
}


extension Atom {
    mutating func appendingParticleGroup(_ particleGroup: ParticleGroup) {
        let newParticleGroups = ParticleGroups(
            [particleGroup].appending(contentsOf: self.particleGroups)
        )
        
        self = Atom(
            metaData: metaData,
            particleGroups: newParticleGroups
        )
    }
}
