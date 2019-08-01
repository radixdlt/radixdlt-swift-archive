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

public protocol DictionaryConvertibleMutable: DictionaryConvertible {
    var dictionary: [Key: Value] { get set }
    
    subscript(key: Key) -> Value? { get }
    mutating func valueForKey(key: Key, ifAbsent createValue: () -> Value) -> Value
    
    @discardableResult
    mutating func removeValue(forKey key: Key) -> Value?
}

// MARK: - Subscript
public extension DictionaryConvertibleMutable {
    subscript(key: Key) -> Value? {
        get { return dictionary[key] }
        set { dictionary[key] = newValue }
    }
}

public extension DictionaryConvertibleMutable {
    mutating func valueForKey(key: Key, ifAbsent createValue: () -> Value) -> Value {
        return dictionary.valueForKey(key: key, ifAbsent: createValue)
    }
    
    /// Returns `value` that was removed, if any
    @discardableResult
    mutating func removeValue(forKey key: Key) -> Value? {
        return dictionary.removeValue(forKey: key)
    }
}
