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
        let (vectorJsonString, proposedFileName) = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: 9, to: bob)
            }
        )
        print(proposedFileName)
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_no_data_single_transfer_small_amount_no_change() {
        let smallSupply: PositiveSupply = 10
        (mapper, token) = mapperWithToken(supply: .fixed(to: smallSupply))
        let (vectorJsonString, proposedFileName) = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: smallSupply.amount, to: bob)
            }
        )
        print(proposedFileName)
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    // MARK: Huge Amount
    // ==================
    // ==================
    // ==================
    func testMakeVector_no_data_single_transfer_huge_amount_with_change() {
        let (vectorJsonString, proposedFileName) = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: PositiveSupply.max.amount - 1337, to: bob)
            }
        )
        print(proposedFileName)
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_no_data_single_transfer_huge_amount_no_change() {
        let (vectorJsonString, proposedFileName) = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: allTokens, to: bob)
            }
        )
        print(proposedFileName)
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    
    // MARK: *** DATA ***
    // ==================
    // ==================
    // ==================
    // MARK: No Transfers
    func testMakeVector_data_no_transfer_burn_action() {
        let (vectorJsonString, proposedFileName) = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Burn(amount: 5)
            }
        )
        print(proposedFileName)
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_data_no_transfer_message_action() {
        let (vectorJsonString, proposedFileName) = makeVectorJSON(
            Transaction(TokenContext(rri: .irrelevant, actor: alice)) {
                Message(text: "Hey you!", to: clara)
            }
        )
        print(proposedFileName)
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    
    func testMakeVector_data_no_transfer_put_unique_action() {
        let (vectorJsonString, proposedFileName) = makeVectorJSON(
            Transaction(TokenContext(rri: .irrelevant, actor: alice)) {
                PutUnique("Unicorn")
            }
        )
        print(proposedFileName)
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
//    
//    func testMakeVector_data_no_transfer_encrypted_message() {
//        let (vectorJsonString, proposedFileName) = makeVectorJSON(
//            Transaction(TokenContext(rri: .irrelevant, actor: alice)) {
//                Message
//            }
//        )
//        print(proposedFileName)
//        print(vectorJsonString)
//        XCTAssertFalse(vectorJsonString.isEmpty)
//        
//    }
    
    // MARK: Single Transfer
    // ==================
    // ==================
    // ==================
    
    // MARK: Small Amount
    // ==================
    // ==================
    // ==================
    func testMakeVector_data_single_transfer_small_amount_with_change() {
        let (vectorJsonString, proposedFileName) = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: 9, to: bob)
                 PutUnique("Unicorn")
            }
        )
        print(proposedFileName)
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_data_single_transfer_small_amount_no_change() {
        let smallSupply: PositiveSupply = 10
        (mapper, token) = mapperWithToken(supply: .fixed(to: smallSupply))
        let (vectorJsonString, proposedFileName) = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Message(text: "Hey you!", to: clara)
                Transfer(amount: smallSupply.amount, to: bob)
            }
        )
        print(proposedFileName)
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_huge_atom() {
        let supply: Supply = 21_000_000
        (mapper, token) = mapperWithToken(supply: .mutable(initial: supply))
        let (vectorJsonString, proposedFileName) = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Message(text: "Hey you!", to: bob)
                Message(text: "The Legend of Zelda is an action-adventure video game franchise created by Japanese game designers Shigeru Miyamoto and Takashi Tezuka. It is primarily developed and published by Nintendo, although some portable installments and re-releases have been outsourced to Capcom, Vanpool, and Grezzo. The gameplay incorporates action-adventure and elements of action RPG games.", to: clara)
                Message(text: "The series centers on the various incarnations of Link; a courageous young man, with pointy elf-like ears and Princess Zelda; the mortal reincarnation of the goddess Hylia. Although his origins and backstory differ from game to game, Link is often given the task of rescuing the kingdom of Hyrule from Ganon, an evil warlord turned demon who is the principal antagonist of the series; however, other settings and antagonists have appeared in several games. The plots commonly involve the Triforce, a sacred relic left behind by goddesses that created Hyrule; Din, Farore and Nayru, representing the virtues of Courage, Wisdom and Power that when combined together are omnipotent.\n\nSince the original Legend of Zelda was released in 1986, the series has expanded to include 19 entries on all of Nintendo's major game consoles, as well as a number of spin-offs. An American animated TV series based on the games aired in 1989 and individual manga adaptations commissioned by Nintendo have been produced in Japan since 1997. The Legend of Zelda is one of Nintendo's most prominent and successful franchises; several of its entries are considered to be among the greatest video games of all time.", to: diana)
                Transfer(amount: 1_000_000, to: bob)
                Mint(amount: 2_000_000, creditNewlyMintedTokensTo: diana)
                Transfer(amount: 123456, to: clara)
                Burn(amount: 1_000_000)
                PutUnique("Unicorn")
                Transfer(amount: 237, to: diana)
                Burn(amount: 1337)
                Mint(amount: 21_000_000)
                Transfer(amount: 10, to: bob)
                Transfer(amount: 20, to: diana)
                Message(text: "The Legend of Zelda games feature a mix of puzzles, action, adventure/battle gameplay, and exploration. These elements have remained constant throughout the series, but with refinements and additions featured in each new game. Later games in the series also include stealth gameplay, where the player must avoid enemies while proceeding through a level, as well as racing elements. Although the games can be beaten with a minimal amount of exploration and side quests, the player is frequently rewarded with helpful items or increased abilities for solving puzzles or exploring hidden areas. Some items are consistent and appear many times throughout the series (such as bombs and bomb flowers, which can be used both as weapons and to open blocked or hidden doorways; boomerangs, which can kill or paralyze enemies; keys for locked doors; magic swords, shields, and bows and arrows), while others are unique to a single game. Though the games contain many role-playing elements (Zelda II: The Adventure of Link is the only one to include an experience system), they emphasize straightforward hack and slash-style combat over the strategic, turn-based or active time combat of series like Final Fantasy. The game's role-playing elements, however, have led to much debate over whether or not the Zelda games should be classified as action role-playing games, a genre on which the series has had a strong influence.", to: bob)
                Transfer(amount: 1337, to: bob)
                
            }
        )
        print(proposedFileName)
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
        let (vectorJsonString, proposedFileName) = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: bigSupply.amount - 1337, to: bob)
                Burn(amount: 5)
            }
        )
        print(proposedFileName)
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_data_single_transfer_huge_amount_no_change() {
        let bigSupply = Supply.max - 1234
        (mapper, token) = mapperWithToken(supply: .mutable(initial: bigSupply))
        let (vectorJsonString, proposedFileName) = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: allTokens, to: bob)
                PutUnique("Unicorn")
            }
        )
        print(proposedFileName)
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    
    func testMakeVector_data_single_transfer_no_change_small_amount_unique_and_message() {
        let smallSupply: PositiveSupply = 10
        (mapper, token) = mapperWithToken(supply: .fixed(to: smallSupply))
        
        let (vectorJsonString, proposedFileName) = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                PutUnique("Unicorn")
                Transfer(amount: smallSupply.amount, to: bob)
                Message(text: "Hey you!", to: diana)
            }
        )
        print(proposedFileName)
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    

    // MARK: Multiple Transfers
    // ==================
    // ==================
    // ==================
    
    func testMakeVector_data_multiple_transfers_small_amounts_with_change_unique() {
        let (vectorJsonString, proposedFileName) = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Transfer(amount: 9, to: bob)
                Transfer(amount: 42, to: clara)
                PutUnique("Unicorn")
            }
        )
        print(proposedFileName)
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
    func testMakeVector_data_multiple_transfers_small_and_big_amount_messages() {
        let (vectorJsonString, proposedFileName) = makeVectorJSON(
            Transaction(TokenContext(rri: rri, actor: alice)) {
                Message(text: "All I ever wanted", to: clara)
                Transfer(amount: 123, to: bob)
                Message(text: "All I ever needed", to: clara)
                Transfer(amount: PositiveAmount.max - 123, to: clara)
                Message(text: "Is you, in my arms", to: clara)
            }
        )
        print(proposedFileName)
        print(vectorJsonString)
        XCTAssertFalse(vectorJsonString.isEmpty)
    }
    
}

// MARK: Atom preparation
private extension GenerateTestVectorsForLedgerApp {
    
    
    func save(stringContent: String, toFileNamed: String) throws {
        
        // get URL to the the directory in the sandbox
        let folderURL = try FileManager.default.url(for: .desktopDirectory, in: .allDomainsMask, appropriateFor: nil, create: true)
        
        // add a filename
        let fileUrl = folderURL.appendingPathComponent(toFileNamed)
        
        print("Saving file at: \(fileUrl.absoluteString)")
        
        // write to it
        try stringContent.write(to: fileUrl, atomically: true, encoding: .utf8)
    }
    
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
    ) -> (vectorJson: String, proposedFileName: String) {
        let description = makePretty(nonPrettyDescription)
        let vector = makeVector(description: description, makeTransaction(), appendingAdhocParticleWrappedInSeparateGroups: makeParticles())
        let jsonData = try! jsonEncoder.encode(vector)
        
        let vectorJSON = String(data: jsonData, encodingForced: .utf8)
        let proposedFileName = vector.descriptionOfTest.replacingOccurrences(of: " ", with: "_") + ".json"
        
        
        try! save(stringContent: vectorJSON, toFileNamed: proposedFileName)
        
        return (
            vectorJson: vectorJSON,
            proposedFileName: proposedFileName
        )
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
        
        
        let atomToTransferMapper = DefaultAtomToTokenTransferMapper()
        let actionsPublisher = atomToTransferMapper.mapAtomToActions(atom)
        
        let recorder = actionsPublisher.record()
        
        let transfers: [TokensTransfer]
        do {
            let transferActions: [TransferTokensAction] = try wait(for: recorder.firstOrError, timeout: 1.5)
            transfers = transferActions.map(TokensTransfer.init)
        } catch {
            transfers = []
        }
        
        
        return LedgerSignAtomTestVector.init(description: description, magic: magic, atom: atom, actor: alice, transfers: transfers)
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
