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

public protocol DataConvertible: LengthMeasurable {
    var asData: Data { get }
    var bytes: [Byte] { get }
    func toData(minByteCount: Int?, concatMode: ConcatMode) -> Data
    func toHexString(case: String.Case?, mode: StringConversionMode?) -> HexString
    func toBase64String(minLength: Int?) -> Base64String
    func toBase58String(minLength: Int?) -> Base58String
}

// MARK: - Default Implementation
public extension DataConvertible {
    func toData(minByteCount expectedLength: Int? = nil, concatMode: ConcatMode = .prepend) -> Data {
      
        guard let expectedLength = expectedLength else {
            return self.asData
        }
        var modified: Data = self.asData
        let new = Byte(0x0)
        while modified.length < expectedLength {
            switch concatMode {
            case .prepend: modified = new + modified
            case .append: modified = modified + new
            }
        }
        return modified
        
    }

    var bytes: [Byte] {
        return asData.bytes
    }
}

// MARK: - LengthMeasurable
public extension DataConvertible {
    var length: Int {
        return asData.bytes.count
    }
}

// MARK: - Integer
public extension DataConvertible {
    var unsignedBigInteger: BigUnsignedInt {
        return BigUnsignedInt(asData)
    }
}

// MARK: - Conformance
extension Array: DataConvertible where Element == Byte {
    public var asData: Data {
        return Data(self)
    }
}
