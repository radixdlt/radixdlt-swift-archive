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

public enum Spin: Int, Hashable, Codable, CustomStringConvertible {
    case neutral = 0
    // swiftlint:disable:next identifier_name
    case up = 1
    case down = -1
}

public extension Spin {
    var description: String {
        switch self {
        case .neutral: return "neutral"
        case .up: return "up"
        case .down: return "down"
        }
    }
    
    var inverted: Spin {
        switch self {
        case .neutral: incorrectImplementation("Cannot invert neutral")
        case .down: return .up
        case .up: return .down
        }
    }
}

extension Spin: DSONEncodable {
    public func toDSON(output: DSONOutput) throws -> DSON {
        return try CBOR(integerLiteral: rawValue).toDSON(output: output)
    }
}
