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

// 
public extension Data {
    func toHexString(case: String.Case? = nil, mode: StringConversionMode? = nil) -> HexString {
        let hexString = HexString(data: asData)
        var hex = hexString.stringValue.changeCaseIfNeeded(to: `case`)
        switch mode {
        case .none: break
        case .minimumLength(let minimumLength, let concatMode)?:
            hex.prependOrAppend(character: "0", toLength: minimumLength, mode: concatMode)
        case .trim?: hex.trim(character: "0")
        }
        
        return HexString(validated: hex)
    }
    
    func toBase64String(minLength: Int? = nil) -> Base64String {
        let data = toData(minByteCount: minLength, concatMode: .prepend)
        return Base64String(data: data)
    }
    
    func toBase58String(minLength: Int? = nil) -> Base58String {
        let data = toData(minByteCount: minLength, concatMode: .prepend)
        return Base58String(data: data)
    }
}
