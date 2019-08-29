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
import SwiftUI
import Combine
import KeychainSwift

/// A type-erasing key-value store that wraps some type confirming to `KeyValueStoring`
final class KeyValueStore<Key, SaveOptions>: ObservableObject, KeyValueStoring where Key: KeyConvertible & ExpressibleByStringLiteral, Key.StringLiteralType == String, SaveOptions: SaveOptionConvertible {

    private let cancellable: Cancellable?
    let objectWillChange = PassthroughSubject<Void, Never>()

    private let _save: (Any, String, AnySaveOptionsConvertible) -> Void
    private let _load: (String) -> Any?
    private let _delete: (String) -> Void

    init<Concrete>(_ concrete: Concrete) where Concrete: KeyValueStoring, Concrete.Key == Key, Concrete.SaveOptions == SaveOptions {
        _save = { concrete.save(value: $0, forKey: $1, saveOptions: $2) }
        _load = { concrete.loadValue(forKey: $0) }
        _delete = { concrete.deleteValue(forKey: $0) }

        if concrete is UserDefaults {

            cancellable = NotificationCenter.default
                .publisher(for: UserDefaults.didChangeNotification)
                .map { _ in () }
                .subscribe(objectWillChange)

        } else { cancellable = nil }
    }
}

// MARK: - AnyKeyValueStoring Conformance
extension KeyValueStore {
    func save(value: Any, forKey key: String, saveOptions: AnySaveOptionsConvertible) {
        _save(value, key, saveOptions)
        objectWillChange.send()
    }

    func loadValue(forKey key: String) -> Any? {
        return _load(key)
    }

    func deleteValue(forKey key: String) {
        _delete(key)
        objectWillChange.send()
    }
}
