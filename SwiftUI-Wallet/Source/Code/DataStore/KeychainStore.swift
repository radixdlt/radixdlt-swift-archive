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
import RadixSDK

final class KeychainStore: ObservableObject  {
    private let keychain: KeychainSwift

    // TODO change to protocol
    init(keychain: KeychainSwift = .init()) {
        self.keychain = keychain
    }

    let objectWillChange = PassthroughSubject<Void, Never>()
}

extension KeychainStore {
    var identity: AbstractIdentity? {
        get {
            load(for: .identity)
        }
        set {
            if let newIdentity = newValue {
                save(value: newIdentity, for: .identity)
            } else {
                deleteValue(for: .identity)
            }
        }
    }

    var mnemonic: Mnemonic? {
        get {
           loadCodable(for: .mnemonic)
        }
        set {
            if let newMnemonic = newValue {
                saveCodable(newMnemonic, for: .mnemonic)
            } else {
                deleteValue(for: .mnemonic)
            }
        }
    }

    var isWalletSetup: Bool {
        return identity != nil || mnemonic != nil
    }

}

extension KeychainStore {
    func load<Value>(for key: Key) -> Value? {
        guard let anyValue = keychain.loadValue(for: key.rawValue), let value = anyValue as? Value else {
            return nil
        }
        return value
    }

    /// Saves items in Keychain using access option `kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly`
    /// Do not that means that if the user unsets the iOS passcode for their iOS device, then all data
    /// will be lost, read more in [Apple Docs][1]
    ///
    /// [1]: https://developer.apple.com/documentation/security/ksecattraccessiblewhenpasscodesetthisdeviceonly
    ///
    func save<Value>(value: Value, for key: Key, access: KeychainSwiftAccessOptions = .accessibleWhenPasscodeSetThisDeviceOnly) {
        keychain.save(value: value, for: key.rawValue, access: access)
        objectWillChange.send()
    }

    func deleteValue(for key: Key) {
        keychain.deleteValue(for: key.rawValue)
        objectWillChange.send()
    }
}

// MARK: - Codable
extension KeychainStore {

    func loadCodable<C>(
        for key: Key,
        jsonDecoder: JSONDecoder = .init()
    ) -> C? where C: Codable {
        loadCodable(C.self, for: key, jsonDecoder: jsonDecoder)
    }

    func loadCodable<C>(
        _ modelType: C.Type,
        for key: Key,
        jsonDecoder: JSONDecoder = .init()
    ) -> C? where C: Codable {

        guard
            let json: Data = load(for: key),
            let model = try? jsonDecoder.decode(C.self, from: json)
            else { return nil }
        return model
    }

    func saveCodable<C>(
        _ model: C,
        for key: Key,
        access: KeychainSwiftAccessOptions = .accessibleWhenPasscodeSetThisDeviceOnly,
        jsonEncoder: JSONEncoder = .init()
    ) where C: Codable {
        do {
            let json = try jsonEncoder.encode(model)
            save(value: json, for: key, access: access)
        } catch {
            // TODO change to print
            fatalError("Failed to save codable, error: \(error)")
        }
    }
}

// MARK: - Key
extension KeychainStore {
    enum Key: String {
        case identity, mnemonic
    }
}

// MARK: 3rd Party `KeychainSwift` extension
extension KeychainSwift {
    typealias Key = KeychainStore.Key

    func loadValue(for key: String) -> Any? {
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
    func save(value: Any, for key: String, access: KeychainSwiftAccessOptions) {
        if let data = value as? Data {
            set(data, forKey: key, withAccess: access)
        } else if let bool = value as? Bool {
            set(bool, forKey: key, withAccess: access)
        } else if let string = value as? String {
            set(string, forKey: key, withAccess: access)
        } else {
            fatalError("Unable to save: \(value), for key: \(key)")
        }
    }

    func deleteValue(for key: String) {
        delete(key)
    }
}
