/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation
@testable import RadixSDK
import XCTest
import RxSwift
import RxTest
import RxBlocking


//extension NodeDiscoveryHardCoded {
//    static var localhost: NodeDiscoveryHardCoded {
//        do {
//            return try NodeDiscoveryHardCoded(hosts: [Host.local()], universeConfig: UniverseConfig.localnet, strategyIfUnsuitable: .throwError)
//        } catch {
//            incorrectImplementation("Error: \(error)")
//        }
//    }
//}
//
//extension RPCClientsRetainer {
//    class func futureRpcClient(nodeDiscovery: NodeDiscovery) -> Observable<RPCClient> {
//        return nodeDiscovery.loadNodes().map { nodes -> RPCClient in
//            let node = nodes[0]
//            return RPCClientsRetainer.rpcClient(node: node)
//        }
//    }
//}

//class WebsocketTest: XCTestCase {
//
//    override func invokeTest() {
//        guard isConnectedToLocalhost() else { return }
//        super.invokeTest()
//    }
//
//    func makeRpcClient(
//        nodeDiscovery: NodeDiscovery = NodeDiscoveryHardCoded.localhost,
//        timeout: TimeInterval = 1,
//        failOnTimeout: Bool = true,
//        _ function: String = #function, _ file: String = #file
//        ) -> RPCClient? {
//        return RPCClientsRetainer.futureRpcClient(nodeDiscovery: nodeDiscovery).blockingTakeFirst(timeout: timeout, failOnTimeout: failOnTimeout, failOnNil: true, function: function, file: file)
//    }
//}

class LocalhostNodeTest: XCTestCase {

    override func invokeTest() {
        guard isConnectedToLocalhost() else { return }
        super.invokeTest()
    }
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
}
