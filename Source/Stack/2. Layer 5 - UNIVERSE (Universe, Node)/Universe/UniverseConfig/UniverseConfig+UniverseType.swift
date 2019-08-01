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
        case .public: return "Public"
        case .development: return "Development"
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
