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

import Foundation
import XCTest

private let timeoutInSecondsEnoughForPOW: Int = 10
extension TimeInterval {
    static var enoughForPOW: Self { .init(timeoutInSecondsEnoughForPOW) }
    static var ms100: Self { .init(0.1) }
}

extension DispatchTimeInterval {
    static var enoughForPOW: Self { .seconds(timeoutInSecondsEnoughForPOW) }
    static var ms100: Self { .milliseconds(100) }
}

class TestCase: XCTestCase {
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }
}

internal extension TestCase {
    func forwardFailure(
        description: String,
        inFile filePath: String = #file,
        atLine line: UInt = #line,
        expected: Bool = false
    ) {
        recordFailure(
            withDescription: description,
            inFile: filePath,
            atLine: Int(line),
            expected: expected
        )
    }
}
