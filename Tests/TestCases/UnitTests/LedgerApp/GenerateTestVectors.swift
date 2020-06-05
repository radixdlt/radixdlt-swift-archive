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
    }
    

    private let jsonEncoder = RadixJSONEncoder(outputFormat: .prettyPrinted)
    private let testCasePrefix = "testMakeVector_"
    
    private var token: TokenConvertible!
    private var rri: ResourceIdentifier { token.tokenDefinitionReference }
}

// MARK: Vector Generation
extension GenerateTestVectorsForLedgerApp {
    func testMakeVector_no_data_single_transfer_of_short_rri_no_change_small_amount() {
        let supply: PositiveSupply = 1
        (mapper, token) = mapperWithToken(symbol: "APA", supply: .fixed(to: supply))
        
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: supply.amount, to: bob)
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_no_data_single_transfer_of_short_rri_no_change_huge_amount() {
        let supply: PositiveSupply = .max
        (mapper, token) = mapperWithToken(symbol: "APA", supply: .fixed(to: supply))
        
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: supply.amount, to: bob)
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_data_putUniqueAction_single_transfer_of_short_rri_no_change_small_amount() {
        let supply: PositiveSupply = 1
        (mapper, token) = mapperWithToken(symbol: "APA", supply: .fixed(to: supply))
        
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                PutUnique("Unicorn")
                Transfer(amount: supply.amount, to: bob)
            }
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_data_unallocated_single_transfer_of_short_rri_no_change_small_amount() {
        let supply: PositiveSupply = 1
        (mapper, token) = mapperWithToken(symbol: "APA", supply: .fixed(to: supply))
        
        let vectorJsonString = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: supply.amount, to: bob)
            },
            appendingAdhocParticleWrappedInSeparateGroups: [
                AnySpunParticle(
                    spin: .up,
                    particle: UnallocatedTokensParticle(amount: .min, tokenDefinitionReference: .init(address: diana, name: .irrelevant))
                )
            ]
        )
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
}

// MARK: Atom preparation
private extension GenerateTestVectorsForLedgerApp {
    
    func mapperWithToken(
        symbol: Symbol,
        supply: CreateTokenAction.InitialSupply.SupplyTypeDefinition
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
        
        
        return LedgerSignAtomTestVector(description: description, magic: magic, atom: atom)
    }
}

// MARK: Extension/Helpers
extension TokenDefinition {
    init(createTokenAction: CreateTokenAction) {
        self.init(
            symbol: createTokenAction.symbol,
            name: createTokenAction.name,
            tokenDefinedBy: createTokenAction.creator,
            granularity: createTokenAction.granularity,
            description: createTokenAction.description,
            tokenSupplyType: createTokenAction.tokenSupplyType,
            iconUrl: createTokenAction.iconUrl,
            tokenPermissions: createTokenAction.tokenPermissions,
            supply: createTokenAction.supply
        )
    }
}

extension PositiveSupply {
    var amount: PositiveAmount {
        PositiveAmount(other: self)
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
