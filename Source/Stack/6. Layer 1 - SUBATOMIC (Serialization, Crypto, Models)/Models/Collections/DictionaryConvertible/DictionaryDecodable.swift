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

public protocol DictionaryDecodable: Decodable, DictionaryConvertible {
    static var keyDecoder: (String) throws -> Key { get }
    static var valueDecoder: (String) throws -> Value { get }
}

public extension DictionaryDecodable where Key: StringInitializable, Value: StringInitializable {
   
    static var keyDecoder: (String) throws -> Key {
        return {
            try Key(string: $0)
        }
    }
    
    static var valueDecoder: (String) throws -> Value {
        return {
            try Value(string: $0)
        }
    }
   
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let map: Map = try container.decode(StringDictionary.self)
            .mapKeys { try Self.keyDecoder($0) }
            .mapValues { try Self.valueDecoder($0) }
        try self.init(validate: map)
    }
}

public protocol DictionaryEncodable: Encodable, DictionaryConvertible {
    static var keyEncoder: (Key) throws -> String { get }
    static var valueEncoder: (Value) throws -> PrefixedStringWithValue { get }
}

public typealias DictionaryCodable = DictionaryDecodable & DictionaryEncodable

extension String: PrefixedJsonEncodable {
    public var prefixedString: PrefixedStringWithValue {
        return PrefixedStringWithValue(value: self, prefix: .string)
    }
}

// MARK: - Encodable
public extension DictionaryEncodable where Key: StringRepresentable {
    static var keyEncoder: (Key) throws -> String {
        return {
            return $0.stringValue
        }
    }
}

public extension DictionaryEncodable where Value: PrefixedJsonEncodable {
    static var valueEncoder: (Value) throws -> PrefixedStringWithValue {
        return {
            $0.prefixedString
        }
    }
}

public extension Encodable where Self: DictionaryEncodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        let map = try [String: String](uniqueKeysWithValues: dictionary.map {
            (
                try Self.keyEncoder($0.key),
                try Self.valueEncoder($0.value).identifer
            )
        })
        try container.encode(map)
    }
}
