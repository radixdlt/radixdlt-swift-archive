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

class WebsocketTest: XCTest {

    private let disposeBag = DisposeBag()
    
    func makeApiClient(
        nodeDiscovery: NodeDiscovery = Node.localhost(port: 8080),
        timeout: TimeInterval = 1,
        failOnNoConnection: Bool = false,
    _ function: String = #function, _ file: String = #file) -> DefaultAPIClient? {
        let apiClient = DefaultAPIClient(nodeDiscovery: nodeDiscovery)
        do {
            // `take()` operator is absolutely crucial, read "Waiting on non-completing sequences": http://rx-marin.com/post/rxblocking-part1/
            let _ = try apiClient.websocketStatus.filter { $0.isReady }.take(1).toBlocking(timeout: timeout).toArray()
            return apiClient
        } catch {
            print("❗️Localhost is not running, skipped running test: `\(function)` in `\(file)`")
            XCTAssertFalse(failOnNoConnection)
            return nil
        }
    }
    
}
