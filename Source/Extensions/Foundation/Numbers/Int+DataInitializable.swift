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

public extension BinaryInteger {
    init(validData: Data) {
        self = validData.withUnsafeBytes({ (bytes: UnsafeRawBufferPointer) -> Self in
            return bytes.load(as: Self.self)
        })
    }
    
    init(data: Data) throws {
        let expectedByteCount = MemoryLayout<Self>.size
        if data.count > expectedByteCount {
            throw IntFromDataError.incorrectByteCount(expected: expectedByteCount, butGot: data.count)
        }
        self.init(validData: data)
    }
}

public enum IntFromDataError: Swift.Error {
    case incorrectByteCount(expected: Int, butGot: Int)
}

extension UInt8: DataInitializable {}
extension Int8: DataInitializable {}

extension UInt16: DataInitializable {}
extension Int16: DataInitializable {}

extension UInt32: DataInitializable {}
extension Int32: DataInitializable {}

extension UInt64: DataInitializable {}
extension Int64: DataInitializable {}

