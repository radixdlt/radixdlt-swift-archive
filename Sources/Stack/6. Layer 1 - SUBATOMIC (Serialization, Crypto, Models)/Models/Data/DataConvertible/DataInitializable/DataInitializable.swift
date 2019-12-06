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

public protocol DataInitializable {
    init(data: Data) throws
}

public extension DataInitializable {
 
    init(base64: Base64String) throws {
        try self.init(data: base64.asData)
    }
    init(base58: Base58String) throws {
        try self.init(data: base58.asData)
    }
    
    init(hex: HexString) throws {
        try self.init(data: hex.asData)
    }
    
    init(base64String: String) throws {
        try self.init(base64: try Base64String(string: base64String))
    }
    
    init(base58String: String) throws {
        try self.init(base58: try Base58String(string: base58String))
    }
    
    init(hexString: String) throws {
        try self.init(hex: try HexString(string: hexString))
    }
}
