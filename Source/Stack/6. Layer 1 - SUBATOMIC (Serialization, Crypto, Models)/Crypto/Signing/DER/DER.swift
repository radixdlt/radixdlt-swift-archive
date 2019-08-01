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

/// Data on [DER encoding][1]
///
/// [1]: https://en.wikipedia.org/wiki/X.690#DER_encoding
public struct DER:
    DataInitializable,
    MinLengthSpecifying,
    MaxLengthSpecifying,
    DataConvertible,
    Equatable {
    // swiftlint:enable colon
    
    private let derEncodedData: Data
    public static let minLength = 68
    public static let maxLength = 71
    
    public init(data: Data) throws {
        try DER.validateMaxLength(of: data)
        try DER.validateMinLength(of: data)
        self.derEncodedData = data
    }
    
    public init(signature: Signature) {
        
        let byteCount: (DataConvertible) -> Data = {
            return $0.length.evenNumberedBytes
        }
        
        let encode: (Signature.Part) -> Data = {
            let numberBytes = $0.bytes
            var bytes = [Byte]()
            if numberBytes[0] > 0x7f {
                bytes = [0x0] + numberBytes
            } else {
                bytes = numberBytes
            }
            return DERDecoder.DERCode.integerCode.encodableData + byteCount(bytes) + bytes
        }
        let rAndsEncoded: DataConvertible = encode(signature.r) + encode(signature.s)
        let derEncodedData = DERDecoder.DERCode.sequenceCode.encodableData + byteCount(rAndsEncoded) + rAndsEncoded
        self.derEncodedData = derEncodedData
    }
}

// MARK: - Methods
public extension DER {
    func decoded() -> Data {
        return DERDecoder.decodeData(derEncodedData)
    }
}

// MARK: - DataConvertible
public extension DER {
    var asData: Data {
        return derEncodedData
    }
}

public protocol DERConvertible {
    func toDER() throws -> DER
}

public protocol DERInitializable {
    init(der: DER) throws
}
