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

/// An ECDSA signature
public struct Signatures:
    CBORDictionaryConvertible,
    Equatable,
    ExpressibleByDictionaryLiteral,
    Collection,
    Codable {
// swiftlint:enable colon
    
    public typealias Key = EUID
    public typealias Value = Signature
    public let dictionary: Map
    public init(dictionary: Map) {
        self.dictionary = dictionary
    }
    public init(validate dictionary: Map) throws {
        self.init(dictionary: dictionary)
    }
}

// MARK: - Collection
public extension Signatures {
    typealias Element = Dictionary<Key, Value>.Element
    typealias Index = Dictionary<Key, Value>.Index
    
    var startIndex: Index {
        return dictionary.startIndex
    }
    
    var endIndex: Index {
        return dictionary.endIndex
    }
    
    subscript(position: Index) -> Element {
        return dictionary[position]
    }
    
    func index(after index: Index) -> Index {
        return dictionary.index(after: index)
    }
}

// MARK: - ExpressibleByDictionaryLiteral
public extension Signatures {
    init(dictionaryLiteral signatures: (Key, Value)...) {
        self.init(dictionary: Dictionary(uniqueKeysWithValues: signatures))
    }
}

// MARK: - Decodable
public extension Signatures {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringMap = try container.decode([String: Signature].self)
        let map = try [Key: Value](uniqueKeysWithValues: stringMap.map {
            (
                try EUID(string: $0.key),
                $0.value
            )
        })
        self.init(dictionary: map)
    }
}

// MARK: - Encodable
public extension Signatures {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
     
        let dictToEnc = [String: Signature](uniqueKeysWithValues: dictionary.map {
            (
                $0.key.toHexString().stringValue.lowercased(),
                $0.value
            )
        })
        try container.encode(dictToEnc)
    }
}
