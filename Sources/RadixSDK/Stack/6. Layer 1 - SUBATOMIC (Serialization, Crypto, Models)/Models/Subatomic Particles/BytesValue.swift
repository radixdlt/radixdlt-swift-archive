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

// swiftlint:disable colon

public struct BytesValue:
    PrefixedJsonCodableByProxy,
    CBORDataConvertible,
    DataInitializable,
Hashable {
    // swiftlint:enable colon
    
    public let data: Data
    public init(data: Data) throws {
        self.data = data
    }
    
    public init?(dataIfPresent data: Data?) {
        guard let data = data else {
            return nil
        }
        self.data = data
    }
}

// MARK: - PrefixedJsonCodableByProxy
public extension BytesValue {
    typealias Proxy = Base64String
    static let jsonPrefix = JSONPrefix.bytesBase64
    var proxy: Proxy {
        return toBase64String()
    }
    init(proxy: Proxy) throws {
        try self.init(base64: proxy)
    }
}

// MARK: - StringInitializable
public extension BytesValue {
    init(string: String) throws {
        let base64 = try Base64String(string: string)
        try self.init(base64: base64)
    }
}

// MARK: - DataConvertible
public extension BytesValue {
    var asData: Data { return data }
}
