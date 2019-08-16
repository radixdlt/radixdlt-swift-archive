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


class CreateTokenActionTests: XCTestCase {
    
    func testAssertThatInitialSupplyMustMatchGranularity() {
        
        func createGran3(initialSupply: Supply) throws -> CreateTokenAction {
            return try CreateTokenAction.new(
                supply: .mutable(initial: initialSupply),
                granularity: 3
            )
        }
        
        func assertThrows(initialSupply: Supply) {
            XCTAssertThrowsSpecificError(
                try createGran3(initialSupply: initialSupply),
                CreateTokenAction.Error.initialSupplyNotMultipleOfGranularity
            )
        }
        
        func assertNoThrow(initialSupply: Supply) {
            XCTAssertNoThrow(try createGran3(initialSupply: initialSupply))
        }
        
        assertThrows(initialSupply: 2)
        assertNoThrow(initialSupply: 3)
        assertThrows(initialSupply: 4)
        assertThrows(initialSupply: 5)
        assertNoThrow(initialSupply: 6)
        assertNoThrow(initialSupply: 9)
        assertNoThrow(initialSupply: 300)
        assertThrows(initialSupply: 299)
        assertThrows(initialSupply: 301)
        
    }
}
