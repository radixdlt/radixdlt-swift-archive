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

/// Type used as a key to some value, e.g. a wrapper around `UserDefaults`
protocol KeyConvertible {
    init?(rawValue: String)
    var key: String { get }
}

// MARK: - Default Implementation for `enum SomeKey: String`
extension KeyConvertible where Self: RawRepresentable, Self.RawValue == String {
    var key: String { return rawValue }
}

extension KeyConvertible where Self: ExpressibleByStringLiteral, StringLiteralType == String {
    init(stringLiteral keyRawValue: String) {
        guard let key = Self.init(rawValue: keyRawValue) else { fatalError("bad key: \(keyRawValue)") }
        self = key
    }
}
