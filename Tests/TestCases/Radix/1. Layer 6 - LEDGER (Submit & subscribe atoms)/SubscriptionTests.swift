//
//  SubscriptionTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-05-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import XCTest
@testable import RadixSDK
import RxSwift
import RxTest
import RxBlocking

// RLAU 1092
class SubscriptionTests: WebsocketTest {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
    // AC0
    func testSubscribeToAtomsForAddress() {
        // GIVEN
        // A node interaction ("Ledger")
        let nodeInteraction = DefaultNodeInteraction(NodeDiscoveryHardCoded.localhost)

        // WHEN
        // I subscribe to genesis address
        switch nodeInteraction.subscribe(to: xrdAddress).take(2).toBlocking(timeout: 2).materialize() {
        case .completed(let elements):
            // THEN
            // I see that I get two updates (one `isHead` false, one `isHead: true`)
            XCTAssertEqual(elements.count, 2)
           
        case .failed(_, let error): XCTFail("error: \(error)")
        }

    }
    
    // AC1
    func testCancelSubsription() {
        // GIVEN
        // A node interaction ("Ledger")
        let nodeInteraction = DefaultNodeInteraction(NodeDiscoveryHardCoded.localhost)
        // and a subscription
        XCTAssert(nodeInteraction.subscribe(to: xrdAddress)
            .take(1)
            .toBlocking(timeout: 1)
            .materialize()
            .wasSuccessful
        )
        
        
        // WHEN
        // I cancel the subscription
        XCTAssert(nodeInteraction.unsubscribe(from: xrdAddress)
            .take(1)
            .toBlocking(timeout: 1)
            .materialize()
            .wasSuccessful
        )
    }
    
    // AC3
    func testSubscribingUsingSameIdTwice() {
        // GIVEN
        // A node
        guard let rpcClient = makeRpcClient() else { return }
        let subscriberId = SubscriberId(validated: "666")
        // and an existing Subscription
        XCTAssert( rpcClient.subscribe(to: xrdAddress, subscriberId: subscriberId)
            .take(1)
            .toBlocking(timeout: 1)
            .materialize()
            .wasSuccessful
        )
        
        XCTAssertEqual(
            // WHEN
            // I try subscribing using the same subscription id
            rpcClient.subscribe(to: xrdAddress, subscriberId: subscriberId)
                .take(1)
                .toBlocking(timeout: 1)
                .materialize()
                .mapToError(type: RPCError.self),
            // THEN
            RPCError.subscriberIdAlreadyInUse(subscriberId),
            "I get an error saying that the subscriptions already is in use"
        )
    }

}

private let magic: Magic = 63799298
private let xrdAddress: Address = "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor"


private extension RadixIdentity {
    init(privateKey: PrivateKey) {
        self.init(private: privateKey, magic: magic)
    }
    
    init() {
        self.init(magic: magic)
    }
}

extension MaterializedSequenceResult {
    var wasSuccessful: Bool {
        switch self {
        case .completed: return true
        case .failed: return false
        }
    }
    
    func assertThrows<E>(error expectedError: E) -> Bool where E: Swift.Error & Equatable {
        switch self {
        case .completed: return false
        case .failed(_, let anyThrowedError):
            guard let throwedError = anyThrowedError as? E else {
                return false
            }
            return throwedError == expectedError
        }
    }
    
    func mapToError<E>(type expectedErrorType: E.Type) -> E? where E: Swift.Error & Equatable {
        switch self {
        case .completed: return nil
        case .failed(_, let anyThrowedError): return anyThrowedError as? E
        }
    }
}
