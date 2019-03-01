//
//  Particle.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-21.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum AtomModelDecodingError: Swift.Error {
    case jsonDecodingErrorTypeMismatch(expectedType: RadixModelType, butGot: RadixModelType)
}

public protocol RadixModelKey: CodingKey, RawRepresentable where RawValue == String {
    static var modelType: Self { get }
}

public protocol AtomModelConvertible: Codable {
    associatedtype CodingKeys: RadixModelKey

    static var type: RadixModelType { get }
    
    @discardableResult
    static func verifyType(container: KeyedDecodingContainer<CodingKeys>) throws -> RadixModelType
}

public extension AtomModelConvertible {
    
    var type: RadixModelType {
        return Self.type
    }
    
    @discardableResult
    static func verifyType(container: KeyedDecodingContainer<CodingKeys>) throws -> RadixModelType {
        let decodedType = try container.decode(RadixModelType.self, forKey: CodingKeys.modelType)
        
        guard decodedType == Self.type else {
            throw AtomModelDecodingError.jsonDecodingErrorTypeMismatch(expectedType: Self.type, butGot: decodedType)
        }
        return decodedType
    }
}

public protocol ParticleConvertible: Codable {
    var particleType: ParticleType { get }
}

public protocol ParticleModelConvertible: ParticleConvertible, AtomModelConvertible {}

public extension ParticleConvertible {
    func keyDestinations() -> Set<PublicKey> {
        var addresses = Set<Address>()
        
        if let accountable = self as? Accountable {
            addresses.insert(contentsOf: accountable.addresses)
        }
        
        if let identifiable = self as? Identifiable {
            addresses.insert(identifiable.identifier.address)
        }
        
        return addresses.map { $0.publicKey }.asSet
    }
    
    func `as`<P>(_ type: P.Type) -> P? where P: ParticleConvertible {
        guard let specific = self as? P else {
            return nil
        }
        return specific
    }
}
