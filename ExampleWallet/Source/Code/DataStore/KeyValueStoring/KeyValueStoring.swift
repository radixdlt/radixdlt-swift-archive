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

/// A typed simple, non thread safe, non async key-value store accessing values using its associatedtype `Key`
protocol KeyValueStoring: AnyKeyValueStoring {
    associatedtype Key: KeyConvertible
    associatedtype SaveOptions: SaveOptionConvertible
    func save<Value>(value: Value, forKey key: Key, options: SaveOptions, notifyChange: Bool)
    func loadValue<Value>(forKey key: Key) -> Value?
    func deleteValue(forKey key: Key, notifyChange: Bool)
}

// MARK: Save or Delete
extension KeyValueStoring {

    func update<Value>(
        value: Value?,
        forKey key: Key,
        options: SaveOptions = .default,
        notifyChange: Bool = true
    ) {

        if let newValue = value {
            save(value: newValue, forKey: key, options: options, notifyChange: notifyChange)
        } else {
            deleteValue(forKey: key, notifyChange: notifyChange)
        }

    }

    func update<Value>(
        value: Value?,
        forKey key: Key,
        options: SaveOptions = .default,
        notifyChange: Bool = true
    ) where Value: Codable {

        if let newValue = value {
            saveCodable(newValue, forKey: key, options: options, notifyChange: notifyChange)
        } else {
            deleteValue(forKey: key, notifyChange: notifyChange)
        }
        
    }
}
