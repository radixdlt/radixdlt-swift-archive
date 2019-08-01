/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation

// MARK: - Base Conversion
public extension DataConvertible {
    func toHexString(case: String.Case? = nil, mode: StringConversionMode? = nil) -> HexString {
        return asData.toHexString(case: `case`, mode: mode)
    }
    
    func toBase64String(minLength: Int? = nil) -> Base64String {
        return asData.toBase64String(minLength: minLength)
    }
    
    func toBase58String(minLength: Int? = nil) -> Base58String {
        return asData.toBase58String(minLength: minLength)
    }
    
    var hex: String {
        return toHexString().stringValue
    }
    
    var base58: String {
        return toBase58String().stringValue
    }
    
    var base64: String {
        return toBase64String().stringValue
    }
}
