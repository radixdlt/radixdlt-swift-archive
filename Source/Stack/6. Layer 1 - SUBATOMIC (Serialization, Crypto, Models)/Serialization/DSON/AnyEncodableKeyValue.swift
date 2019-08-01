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

/// A fully type-erased container of a keyed-value that is DSONEncodable
public struct AnyEncodableKeyValue: Hashable {
    
    internal let key: String
    private let dsonEncodedValue: DSON
    private let output: DSONOutput
    
    init(key unencodedKey: String, encoded dsonEncodedValue: DSON, output: DSONOutput) {
        self.key = unencodedKey
        self.dsonEncodedValue = dsonEncodedValue
        self.output = output
    }
}

public extension AnyEncodableKeyValue {
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
}

public extension AnyEncodableKeyValue {
    func allowsOutput(of other: DSONOutput) -> Bool {
        return output.allowsOutput(of: other)
    }
    
    func cborEncoded() -> [UInt8] {
        return cborEncodedKey() + dsonEncodedValue
    }
}

private extension AnyEncodableKeyValue {
    func cborEncodedKey() -> [UInt8] {
        return CBOR.utf8String(key).encode()
    }
}

// MARK: - Convenience Init
public extension AnyEncodableKeyValue {
    init<Value>(key: String, encodable: Value, output: DSONOutput) throws where Value: DSONEncodable {
        self.init(key: key, encoded: try encodable.toDSON(output: output), output: output)
    }
}
