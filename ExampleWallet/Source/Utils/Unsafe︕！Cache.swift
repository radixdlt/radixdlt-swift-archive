// 
// MIT License
//
// Copyright (c) 2019 Radix DLT (https://radixdlt.com)
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
import RadixSDK

/// ⚠️ THIS IS TERRIBLE! DONT USE THIS! This is HIGHLY unsafe and secure. It is temporary and will be removed soon.
struct Unsafe︕！Cache {
    enum Key: String {
        case radixIdentity
    }

    static func stringForKey(_ key: Key) -> String? {
        return UserDefaults.standard.string(forKey: key.rawValue)
    }

    static func dataForKey(_ key: Key) -> Data? {
        return UserDefaults.standard.data(forKey: key.rawValue)
    }

    static var radixIdentity: AbstractIdentity? {
        guard
            let radixIdentityData = Unsafe︕！Cache.dataForKey(.radixIdentity),
        let radixIdentity = try? JSONDecoder().decode(AbstractIdentity.self, from: radixIdentityData)
        else { return nil }
        return radixIdentity
    }

    static var isIdentityConfigured: Bool {
        return radixIdentity != nil
    }

    static func unsafe︕！Store(value: Any, forKey key: Key) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }

    static func unsafe︕！Store(identity: AbstractIdentity) {
        let data = try! JSONEncoder().encode(identity)
        unsafe︕！Store(value: data, forKey: .radixIdentity)
    }

    static func deleteIdentity() {
        deleteValueFor(key: .radixIdentity)
    }

    static func deleteValueFor(key: Key) {
        UserDefaults.standard.removeObject(forKey: key.rawValue)
    }
}

extension AbstractIdentity: Codable {
    enum CodingKeys: String, CodingKey {
        case alias, accounts
    }
    
    public convenience init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let accounts = try container.decode([Account].self, forKey: CodingKeys.accounts)
        let alias = try container.decodeIfPresent(String.self, forKey: .alias)
        self.init(accounts: NonEmptyArray(accounts), alias: alias)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(accounts.elements, forKey: CodingKeys.accounts)
        try container.encodeIfPresent(alias, forKey: .alias)
    }
}

extension Account: Codable {
    
    enum AccountType: Int, Codable {
        case keyPair, onlyPublicKey
    }
    
    enum CodingKeys: Int, CodingKey {
        case accountType
        case nestedAccountValue
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let accountType = try container.decode(AccountType.self, forKey: .accountType)
     
        switch accountType {
        case .keyPair:
            let privateKey = try container.decode(PrivateKey.self, forKey: .nestedAccountValue)
            let keyPair = KeyPair(private: privateKey)
            self = .privateKeyPresent(keyPair)
        case .onlyPublicKey:
             self = .privateKeyNotPresent(try container.decode(PublicKey.self, forKey: .nestedAccountValue))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .privateKeyNotPresent(let publicKey):
            try container.encode(AccountType.onlyPublicKey, forKey: .accountType)
            try container.encode(publicKey, forKey: .nestedAccountValue)
        case .privateKeyPresent(let keyPair):
            try container.encode(AccountType.keyPair, forKey: .accountType)
            try container.encode(keyPair.privateKey, forKey: .nestedAccountValue)
        }
    }
}

extension PrivateKey: Codable {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let stringValue = try container.decode(String.self)
        try self.init(hex: stringValue)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.hex)
    }
}
