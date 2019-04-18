//
//  UniverseConfig+UniverseType.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-09.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension UniverseConfig {
    enum UniverseType: Int, IntInitializable, Codable, Equatable, CBOREncodable, DSONEncodable, CaseIterable {
        case `public` = 1
        case development
    }
}

public typealias UniverseConfigType = UniverseConfig.UniverseType

public extension UniverseConfigType {
    
    func encode() -> [UInt8] {
        return CBOR.init(integerLiteral: ordinalValue).encode()
    }
    
    var ordinalValue: Int {
        return rawValue
    }
    
    var name: String {
        switch self {
        case .public: return "RADIX_PUBLIC"
        case .development: return "RADIX_DEVELOPMENT"
        }
    }
}

// MARK: - CaseIterable
public extension UniverseConfigType {
    static var allCases: [UniverseConfigType] {
        return [.public, .development]
    }
}

// MARK: IntInitializable
public extension UniverseConfigType {
    init(int: Int) throws {
        guard let configType = UniverseConfigType(rawValue: int) else {
            throw Error.unsupportedUniverseType(expectedAnyOf: UniverseConfigType.allCases, butGot: int)
        }
        self = configType
    }
}

// MARK: Decodable
public extension UniverseConfigType {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let intValue = try container.decode(Int.self)
        try self.init(int: intValue)
    }
}

// MARK: - CustomStringConvertible
public extension UniverseConfigType {
    var description: String {
        return name
    }
}

// MARK: - Error
public extension UniverseConfigType {
    enum Error: Swift.Error {
        case unsupportedUniverseType(expectedAnyOf: UniverseConfigType.AllCases, butGot: Int)
    }
}

public protocol IntInitializable: ExpressibleByIntegerLiteral, Decodable, ValidValueInitializable where ValidationValue == Int {
    init(int: Int) throws
}

// MARK: - Decodable
public extension IntInitializable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let intValue = try container.decode(Int.self)
        try self.init(int: intValue)
    }
}

public extension IntInitializable {
    init(unvalidated value: ValidationValue) throws {
        try self.init(int: value)
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension IntInitializable {
    init(integerLiteral value: Int) {
        do {
            try self.init(int: value)
        } catch {
            fatalError("Passed bad int value: `\(value)`, error: \(error)")
        }
    }

}

extension Int: IntInitializable {
    public init(int: Int) throws {
        self = int
    }
}
