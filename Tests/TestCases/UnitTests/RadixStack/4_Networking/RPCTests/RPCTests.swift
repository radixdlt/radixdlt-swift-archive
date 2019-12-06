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

class RPCTests: TestCase {

   
    func testDecodingNotificationAtomsNextStatusEvent() throws {
        let json = """
            {
                "method": "Atoms.nextStatusEvent",
                "params": {
                    "status": "STORED",
                    "subscriberId": "B958DB35-0C38-4A5A-8AA4-89CB23673A66",
                },
                "jsonrpc": "2.0"
            }
        """
        
        let jsonData = json.toData()
        
        let notification = try JSONDecoder().decode(RPCNotificationResponse<AtomStatusEvent>.self, from: jsonData)
        XCTAssertEqual(notification.method, .observeAtomStatusNotifications)
        let atomStatusEvent = notification.params
        XCTAssertEqual(atomStatusEvent, .stored)
        
    }

 
}
