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


class WebSocketStatusEquatableTests: TestCase {


    func testDisconnectedToX() {
        func doAssertNotEqualToDisconnected(status webSocketStatus: WebSocketStatus) {
            XCTAssertNotEqual(webSocketStatus, WebSocketStatus.disconnected)
        }
        XCTAssertEqual(WebSocketStatus.disconnected, WebSocketStatus.disconnected)
        doAssertNotEqualToDisconnected(status: .connecting)
        doAssertNotEqualToDisconnected(status: .connected)
        doAssertNotEqualToDisconnected(status: .closing)
        doAssertNotEqualToDisconnected(status: .failed)
    }
    
    
    func testConnectingToX() {
        func doAssertNotEqualToConnecting(status webSocketStatus: WebSocketStatus) {
            XCTAssertNotEqual(webSocketStatus, WebSocketStatus.connecting)
        }
        XCTAssertEqual(WebSocketStatus.connecting, WebSocketStatus.connecting)

        doAssertNotEqualToConnecting(status: .disconnected)
        doAssertNotEqualToConnecting(status: .connected)
        doAssertNotEqualToConnecting(status: .closing)
        doAssertNotEqualToConnecting(status: .failed)
    }
    
    func testConnectedToX() {
        func doAssertNotEqualToConnected(status webSocketStatus: WebSocketStatus) {
            XCTAssertNotEqual(webSocketStatus, WebSocketStatus.connected)
        }
        XCTAssertEqual(WebSocketStatus.connected, WebSocketStatus.connected)
        
        doAssertNotEqualToConnected(status: .disconnected)
        doAssertNotEqualToConnected(status: .connecting)
        doAssertNotEqualToConnected(status: .closing)
        doAssertNotEqualToConnected(status: .failed)
    }

    func testClosingToX() {
        func doAssertNotEqualToClosing(status webSocketStatus: WebSocketStatus) {
            XCTAssertNotEqual(webSocketStatus, WebSocketStatus.closing)
        }
        XCTAssertEqual(WebSocketStatus.closing, WebSocketStatus.closing)
        
        doAssertNotEqualToClosing(status: .disconnected)
        doAssertNotEqualToClosing(status: .connecting)
        doAssertNotEqualToClosing(status: .connected)
        doAssertNotEqualToClosing(status: .failed)
    }
    
    func testFailedToX() {
        func doAssertNotEqualToFailed(status webSocketStatus: WebSocketStatus) {
            XCTAssertNotEqual(webSocketStatus, WebSocketStatus.failed)
        }
        XCTAssertEqual(WebSocketStatus.failed, WebSocketStatus.failed)
        
        doAssertNotEqualToFailed(status: .disconnected)
        doAssertNotEqualToFailed(status: .connecting)
        doAssertNotEqualToFailed(status: .connected)
        doAssertNotEqualToFailed(status: .closing)
    }

}
