//
//  WebsocketTest.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest
import RxSwift
import RxTest
import RxBlocking


extension NodeDiscoveryHardCoded {
    static var localhost: NodeDiscoveryHardCoded {
        return NodeDiscoveryHardCoded(urls: [URLFormatter.localhost])
    }
}

class WebsocketTest: XCTestCase {
    
    private let disposeBag = DisposeBag()
    
    func makeRpcClient(
        nodeDiscovery: NodeDiscovery = NodeDiscoveryHardCoded.localhost,
        timeout: TimeInterval = 1,
        failOnNoConnection: Bool = false,
        _ function: String = #function, _ file: String = #file
    ) -> RPCClient? {
        
        func fail(error: Error? = nil) -> RPCClient? {
            var errorDescriptionOrEmpty = ""
            if let error = error {
                errorDescriptionOrEmpty = ", error: \(error), "
            }
            print("❗️Localhost is not running, skipped running test\(errorDescriptionOrEmpty): `\(function)` in `\(file)`")
            XCTAssertFalse(failOnNoConnection)
            return nil
        }
        
        let rpcObservable =  nodeDiscovery.loadNodes().map {
                WebSockets.webSocket(to: $0[0])
            }.map { (socketToNode: WebSocketToNode) -> DefaultRPCClient in
                JSONRPCClients.rpcClient(websocket: socketToNode)
            }
        
        rpcObservable.subscribe().disposed(by: disposeBag)

        
        do {
            // `take()` operator is absolutely crucial, read "Waiting on non-completing sequences": http://rx-marin.com/post/rxblocking-part1/
            let rpcClients = try rpcObservable.take(1).toBlocking(timeout: 1).toArray()
            guard let rpcClient = rpcClients.first else {
                return fail()
            }
            return rpcClient
        } catch {
            return fail(error: error)
        }
        
    }
    
    // Clean this terrible code duplication up...
    func makeApplicationClient(
        nodeDiscovery: NodeDiscovery = NodeDiscoveryHardCoded.localhost,
        timeout: TimeInterval = 1,
        failOnNoConnection: Bool = false,
        _ function: String = #function, _ file: String = #file
        ) -> RadixApplicationClient? {
        
        func fail(error: Error? = nil) -> RadixApplicationClient? {
            var errorDescriptionOrEmpty = ""
            if let error = error {
                errorDescriptionOrEmpty = ", error: \(error), "
            }
            print("❗️Localhost is not running, skipped running test\(errorDescriptionOrEmpty): `\(function)` in `\(file)`")
            XCTAssertFalse(failOnNoConnection)
            return nil
        }
        
        let applicationClientObs = nodeDiscovery.loadNodes().map {
            DefaultRadixApplicationClient(node: $0[0])
        }
        
        applicationClientObs.subscribe().disposed(by: disposeBag)

        
        do {
            // `take()` operator is absolutely crucial, read "Waiting on non-completing sequences": http://rx-marin.com/post/rxblocking-part1/
            let applicationClients = try applicationClientObs.take(1).toBlocking(timeout: 1).toArray()
            guard let applicationClient = applicationClients.first else {
                return fail()
            }
            return applicationClient
        } catch {
            return fail(error: error)
        }
        
    }
}
