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

public protocol KeyValued: ExpressibleByDictionaryLiteral where Key: Hashable {
    var keys: Dictionary<Key, Value>.Keys { get }
    var values: Dictionary<Key, Value>.Values { get }
    func inserting(value: Value, forKey key: Key) -> Self
    func containsValue(forKey key: Key) -> Bool
    func contains(where predicate: ((key: Key, value: Value)) throws -> Bool) rethrows -> Bool
    func firstKeyForValue(_ value: Value) -> Key?
    func valueFor(key: Key) -> Value?
}

extension Dictionary: KeyValued {
    public func valueFor(key: Key) -> Value? {
        return self[key]
    }
    
    public func inserting(value: Value, forKey key: Key) -> [Key: Value] {
        var dictionary = self
        dictionary.updateValue(value, forKey: key)
        return dictionary
    }
    
    public func firstKeyForValue(_ needle: Value) -> Key? {
        abstract()
    }
}

extension Dictionary where Value: Equatable {
    public func firstKeyForValue(_ needle: Value) -> Key? {
        return first(where: { $0.value == needle })?.key
    }
}

public extension KeyValued {
    func containsValue(forKey key: Key) -> Bool {
        return valueFor(key: key) != nil
    }
    
    func contains(onThrow: () -> Bool, where predicate: ((key: Key, value: Value)) throws -> Bool) -> Bool {
        return contains(where: {
            do {
                return try predicate($0)
            } catch {
                return onThrow()
            }
        })
    }
}

extension KeyValued where Key == MetaDataKey {
    var containsTimestamp: Bool {
        return containsValue(forKey: .timestamp)
    }
}
