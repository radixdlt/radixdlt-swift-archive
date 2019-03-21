//
//  Signatures.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
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

// MARK: - Public Methods
public extension Signatures {
    func containsSignature(for signable: Signable, signedBy ownable: Ownable) throws -> Bool {
        
//        return compactMap {
//            try? SignatureVerifier.verifyThat(
//                signature: $0.value,
//                didSign: signable,
//                usingKey: ownable.owner
//            )
//        }.reduce(false) { $0 || $1 }
        
//        do {
//            return try contains {
//                try SignatureVerifier.verifyThat(
//                    signature: $0.value,
//                    didSign: signable,
//                    usingKey: ownable.owner
//                )
//            }
//        } catch {
//            return false
//        }
        
        return try contains {
            try SignatureVerifier.verifyThat(
                signature: $0.value,
                didSign: signable,
                usingKey: ownable.owner
            )
        }
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

// MARK: - Subscript
public extension Signatures {
    subscript(key: Key) -> Value? {
        return dictionary[key]
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
                $0.key.toHexString().stringValue,
                $0.value
            )
        })
        try container.encode(dictToEnc)
    }
}
