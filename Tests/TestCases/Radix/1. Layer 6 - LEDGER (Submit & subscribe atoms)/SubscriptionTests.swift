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

extension DefaultNodeInteraction {
    convenience init(_ nodeDiscovery: NodeDiscovery) {
        self.init(withNode: nodeDiscovery.loadNodes().map { $0[0] })
    }
}

extension DefaultNodeConnection {
    static func byNodeDiscovery(_ nodeDiscovery: NodeDiscovery) -> Observable<DefaultNodeConnection> {
        return nodeDiscovery.loadNodes().map { nodes -> DefaultNodeConnection in
            let node = nodes[0]
            return DefaultNodeConnection(
                node: node,
                rpcClient: RPCClientsRetainer.rpcClient(node: node),
                restClient: RESTClientsRetainer.restClient(node: node)
            )
        }
    }
}

class SubscriptionTests: LocalhostNodeTest {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
    
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
    
    func testCancelSubsription() {
        // GIVEN
        // A node interaction ("Ledger")
        let nodeInteraction = DefaultNodeInteraction(NodeDiscoveryHardCoded.localhost)
        // and a subscription
        XCTAssertTrue(
            nodeInteraction.subscribe(to: xrdAddress)
                .mapToVoid()
                .blockingWasSuccessfull(timeout: 1)
        )
        
        
        // WHEN
        // I cancel the subscription
        XCTAssertTrue(
            nodeInteraction.unsubscribe(from: xrdAddress)
                .mapToVoid()
                .blockingWasSuccessfull(timeout: 1)
        )
    }
    
    func testSubscribingUsingSameIdTwice() {
        // GIVEN
        // A node
        guard let rpcClient = makeRpcClient() else { return }
        let subscriberId = SubscriberId(validated: "666")
        // and an existing Subscription        
        XCTAssertTrue(
            rpcClient.subscribe(to: xrdAddress, subscriberId: subscriberId)
                .mapToVoid()
                .blockingWasSuccessfull(timeout: 1)
        )
 
        let request = rpcClient.subscribe(to: xrdAddress, subscriberId: subscriberId).take(1)
        
        // THEN: I see that action fails with a validation error
        request.blockingAssertThrows(
            error: RPCError.subscriberIdAlreadyInUse(subscriberId),
            timeout: .enoughForPOW
        )
    }

}

//private let magic: Magic = 63799298
private let xrdAddress: Address = "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor"
//
//
//private extension RadixIdentity {
//    init(privateKey: PrivateKey) {
//        self.init(private: privateKey, magic: magic)
//    }
//
//    init() {
//        self.init(magic: magic)
//    }
//}
