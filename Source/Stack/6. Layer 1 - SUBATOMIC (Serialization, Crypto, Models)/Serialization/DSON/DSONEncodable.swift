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
import SwiftCBOR

// Trick so that we do not have to import `SwiftCBOR` in a lot of places
public typealias CBOR = SwiftCBOR.CBOR
public extension CBOR {
    static func int64(_ int: Int64) -> CBOR {
        if int < 0 {
            return CBOR.negativeInt(UInt64(abs(int)-1))
        } else {
            return CBOR.unsignedInt(UInt64(int))
        }
    }
}
public typealias CBOREncodable = SwiftCBOR.CBOREncodable

public typealias DSON = Data

public protocol DSONEncodable {
    func toDSON(output: DSONOutput) throws -> DSON
}

public extension CBOREncodable {
    func toDSON(output: DSONOutput) throws -> DSON {
        return encode().asData
    }
}

extension Bool: DSONEncodable {}
extension String: DSONEncodable {}
extension UInt64: DSONEncodable {}
