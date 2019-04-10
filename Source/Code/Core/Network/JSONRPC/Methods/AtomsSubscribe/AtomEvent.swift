//
//  AtomEvent.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-29.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct AtomEvent: RadixModelTypeStaticSpecifying, Decodable {
    public let atom: Atom
    public let type: AtomEventType
}

// MARK: - AtomEventType
public extension AtomEvent {
    
    // swiftlint:disable colon
    
    /// The events that we can get from an Atom subscription
    enum AtomEventType:
        String,
        StringInitializable,
        PrefixedJsonDecodable,
        Decodable {
        // swiftlint:enable colon
        
        case store, delete
    }
}

// MARK: - AtomEventType + StringInitializable
public extension AtomEvent.AtomEventType {
    init(string: String) throws {
        guard let event = AtomEvent.AtomEventType(rawValue: string) else {
            throw Error.unsupportedAtomEventType(string)
        }
        self = event
    }
    
    enum Error: Swift.Error {
        case unsupportedAtomEventType(String)
    }
}

// MARK: Decodable
public extension AtomEvent {
    
    enum CodingKeys: String, CodingKey {
        case serializer
        
        case type
        case atom
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        atom = try container.decode(Atom.self, forKey: .atom)
        type = try container.decode(AtomEventType.self, forKey: .type)
    }
}

public extension AtomEvent {
    var store: AtomEvent? {
        guard type == .store else {
            return nil
        }
        return self
    }
    
    var delete: AtomEvent? {
        guard type == .delete else {
            return nil
        }
        return self
    }
}

// MARK: RadixModelTypeStaticSpecifying
public extension AtomEvent {
    static let serializer = RadixModelType.atomEvent
}
