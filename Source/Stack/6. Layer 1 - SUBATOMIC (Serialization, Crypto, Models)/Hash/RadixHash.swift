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
import CryptoSwift

public struct RadixHasher: Hashing {
    public init() {}
    public func hash(data: Data) -> Data {
        return RadixHash(unhashedData: data).asData
    }
}

// swiftlint:disable colon

/// Radix hash relies on the DSON encoding of a type.
public struct RadixHash:
    DataConvertible,
    ArrayConvertible,
    Hashable,
    CustomStringConvertible {
// swiftlint:enable colon

    private let data: Data
    
    // MARK: - Designated initializer
    public init(unhashedData: DataConvertible, hashedBy hasher: Hashing = SHA256TwiceHasher()) {
        self.data = hasher.hash(data: unhashedData.asData)
    }
}

// MARK: - LengthMeasurable
public extension RadixHash {
    var length: Int {
        return bytes.length
    }
}

// MARK: - ArrayConvertible
public extension RadixHash {
    typealias Element = Byte
    var elements: [Element] {
        return data.bytes
    }
}

// MARK: - DataConvertible
public extension RadixHash {
    var asData: Data {
        return data
    }
}

// MARK: - Hashable
public extension RadixHash {
    func hash(into hasher: inout Hasher) {
        hasher.combine(data)
    }
}

public extension RadixHash {
    
    func toEUID() -> EUID {
        do {
            return try EUID(data: data.prefix(EUID.length))
        } catch {
            incorrectImplementationShouldAlwaysBeAble(to: "Create `EUID` (hash id) from `RadixHash`", error)
        }
    }
}

// MARK: - CustomStringConvertible
public extension RadixHash {
    var description: String {
        return toBase64String().stringValue
    }
}
