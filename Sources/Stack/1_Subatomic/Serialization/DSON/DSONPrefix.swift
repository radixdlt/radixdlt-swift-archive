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

/// Encoding type information, for more information see the column "Additional Encoding" in the [DSON][1] table
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/56557727/DSON+Encoding+new
public enum DSONPrefix: Int {
    case bytesBase64 = 0x01
    case euidHex = 0x02
    case hashHex = 0x03
    case addressBase58 = 0x04
    case unsignedBigInteger = 0x05
    case radixResourceIdentifier = 0x06
}

public extension DSONPrefix {
    
    var byte: Byte {
        .init(rawValue)
    }
    
    var additionalInformation: Data {
        byte.asData
    }
}
