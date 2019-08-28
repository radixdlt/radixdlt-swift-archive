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
final class KeyValueStore<Key, SaveOptions>: ObservableObject, KeyValueStoring where Key: KeyConvertible, SaveOptions: SaveOptionConvertible {

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

// MARK: - KeyValueStoring Methods
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


// MARK: - KEY VALUE STORE  -

/// Insensitive values to be stored into e.g. `UserDefaults`, such as `hasAcceptedTermsOfService`
enum PreferencesKey: String, KeyConvertible, CaseIterable {
    case hasAgreedToTermsAndPolicy
}

/// Abstraction of UserDefaults
typealias Preferences = KeyValueStore<PreferencesKey, NoOptions>


// MARK: - UserDefaults + KeyValueStoring
extension UserDefaults: KeyValueStoring {
    typealias Key = PreferencesKey
    typealias SaveOptions = NoOptions


    func deleteValue(forKey key: String) {
        removeObject(forKey: key)
    }

    func save(value: Any, forKey key: String, saveOptions: AnySaveOptionsConvertible) {
        let _ = saveOptions
        self.setValue(value, forKey: key)
    }

    func loadValue(forKey key: String) -> Any? {
        return value(forKey: key)
    }
}



// MARK: 3rd Party `KeychainSwift` + KeyValueStoring
/// Key to senstive values being store in Keychain, e.g. the cryptograpically sensitive keystore file, containing an encryption of your wallets private key.
enum KeychainKey: String, KeyConvertible, CaseIterable {
    case mnemonic
    case seedFromMnemonic
    case pincodeProtectingAppThatHasNothingToDoWithCryptography
}

/// Abstraction of Keychain
typealias SecurePersistence = KeyValueStore<KeychainKey, KeychainSwiftAccessOptions>


extension KeychainSwift: KeyValueStoring {
    typealias Key = KeychainKey
    typealias SaveOptions = KeychainSwiftAccessOptions

    func loadValue(forKey key: String) -> Any? {
        if let data = getData(key) {
            return data
        } else if let bool = getBool(key) {
            return bool
        } else if let string = get(key) {
            return string
        } else {
            return nil
        }
    }

    /// Saves items in Keychain using access option `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`
    /// Do not that means that if the user unsets the iOS passcode for their iOS device, then all data
    /// will be lost, read more in [Apple Docs][1]
    ///
    /// [1]: https://developer.apple.com/documentation/security/ksecattraccessiblewhenpasscodesetthisdeviceonly
    ///
    func save(value: Any, forKey key: String, saveOptions: AnySaveOptionsConvertible) {
        guard let access = saveOptions as? KeychainSwiftAccessOptions else {
            fatalError("expected `KeychainSwiftAccessOptions`, but got: \(saveOptions)")
        }

        if let data = value as? Data {
            set(data, forKey: key, withAccess: access)
        } else if let bool = value as? Bool {
            set(bool, forKey: key, withAccess: access)
        } else if let string = value as? String {
            set(string, forKey: key, withAccess: access)
        } else {
            fatalError("Unable to save: \(value), forKey key: \(key)")
        }
    }

    func deleteValue(forKey key: String) {
        delete(key)
    }
}

//extension KeyValueStoring where SaveOptions == KeychainSwiftAccessOptions {
//    func saveSafe<Value>(value: Value, forKey key: Key) {
//        save(value: value, forKey: key.key, saveOptions: KeychainSwiftAccessOptions.accessibleWhenPasscodeSetThisDeviceOnly)
//    }
//}

//extension KeyValueStoring where SaveOptions == Void {
//    func save<Value>(value: Value, forKey key: Key) {
//        save(value: value, forKey: key, options: Void())
//    }
//}

protocol AnySaveOptionsConvertible {}
protocol SaveOptionConvertible: AnySaveOptionsConvertible {
    static var `default`: Self { get }
}
struct NoOptions: SaveOptionConvertible {
    static var `default`: NoOptions { return NoOptions() }
}
extension KeychainSwiftAccessOptions: SaveOptionConvertible {
    static var `default`: KeychainSwiftAccessOptions { return KeychainSwiftAccessOptions.accessibleWhenPasscodeSetThisDeviceOnly }
}

/// A simple non thread safe, non async, key value store without associatedtypes
protocol AnyKeyValueStoring {
    func save(value: Any, forKey key: String, saveOptions: AnySaveOptionsConvertible)
    func loadValue(forKey key: String) -> Any?
    func deleteValue(forKey key: String)
}


/// A typed simple, non thread safe, non async key-value store accessing values using its associatedtype `Key`
protocol KeyValueStoring: AnyKeyValueStoring {
    associatedtype Key: KeyConvertible
    associatedtype SaveOptions: SaveOptionConvertible
    func save<Value>(value: Value, forKey key: Key, options: SaveOptions)
    func loadValue<Value>(forKey key: Key) -> Value?
    func deleteValue(forKey key: Key)
}

// MARK: Default Implementation making use of `AnyKeyValueStoring` protocol
extension KeyValueStoring {

    func loadValue<Value>(forKey key: Key) -> Value? {
        guard let value = loadValue(forKey: key.key), let typed = value as? Value else { return nil }
        return typed
    }

    func deleteValue(forKey key: Key) {
        deleteValue(forKey: key.key)
    }

    func save<Value>(value: Value, forKey key: Key, options: SaveOptions = .default) {
        save(value: value, forKey: key.key, saveOptions: options)
    }
}

//extension KeyValueStoring {
//    func save<Value>(value: Value, forKey key: Key) {
//        save(value: value, forKey: key, options: .default)
//    }
//}

extension KeyValueStoring where Key: CaseIterable {
    func deleteAll() {
        Key.allCases.forEach { deleteValue(forKey: $0) }
    }
}

// MARK: - Codable
extension KeyValueStoring {
    func loadCodable<C>(
         forKey key: Key,
         jsonDecoder: JSONDecoder = .init()
     ) -> C? where C: Codable {
         loadCodable(C.self, forKey: key, jsonDecoder: jsonDecoder)
     }

     func loadCodable<C>(
         _ modelType: C.Type,
         forKey key: Key,
         jsonDecoder: JSONDecoder = .init()
     ) -> C? where C: Codable {

         guard
             let json: Data = loadValue(forKey: key),
             let model = try? jsonDecoder.decode(C.self, from: json)
             else { return nil }
         return model
     }

     func saveCodable<C>(
         _ model: C,
         forKey key: Key,
         options: SaveOptions = .default,
         jsonEncoder: JSONEncoder = .init()
     ) where C: Codable {
         do {
             let json = try jsonEncoder.encode(model)
            save(value: json, forKey: key, options: options)
         } catch {
             // TODO change to print
             fatalError("Failed to save codable, error: \(error)")
         }
     }
}

//extension KeyValueStoring where Key == KeychainKey, SaveOptions == KeychainSwiftAccessOptions {
//    func saveCodableSafe<C>(
//        _ model: C,
//        forKey key: Key,
//        options: SaveOptions = .default,
//        jsonEncoder: JSONEncoder = .init()
//    ) where C: Codable {
//        saveCodable(model, forKey: key, options: options, jsonEncoder: jsonEncoder)
//    }
//}

// MARK: Convenience
extension KeyValueStoring {
    func isTrue(_ key: Key) -> Bool {
        guard let bool: Bool = loadValue(forKey: key) else { return false }
        return bool == true
    }

    func isFalse(_ key: Key) -> Bool {
        return !isTrue(key)
    }
}


/// Type used as a key to some value, e.g. a wrapper around `UserDefaults`
protocol KeyConvertible {
    var key: String { get }
}

// MARK: - Default Implementation for `enum SomeKey: String`
extension KeyConvertible where Self: RawRepresentable, Self.RawValue == String {
    var key: String { return rawValue }
}

