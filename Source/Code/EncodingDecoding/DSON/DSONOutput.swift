//
//  DSONOutput.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-18.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

private var nextOptions = 0

/// Indicates which properties are included in coded DSON
/// for which output requirements. As an example the "signatures" property in an `Atom` is not included in "hash" output
public struct DSONOutput: OptionSet, CustomStringConvertible {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    private init(line: Int = #line) {
        // adding a default args works around and issue where the empty init was called by the system sometimes and exhusted the available options.
        rawValue = 1 << nextOptions
        nextOptions += 1
    }
}

// MARK: - Presets
public extension DSONOutput {
    /// For calculating hashes
    static let hash = DSONOutput()
    
    /// For use with application interfaces.
    static let api = DSONOutput()
    
    /// For use when communicating to other nodes.
    static let wire = DSONOutput()
    
    /// For use when writing data to persistent storage.
    static let persist = DSONOutput()

    /// Never results in output, of limited use
    static let none: DSONOutput = []
    
    /// Mode that always results in output.
    static let all: DSONOutput = [.hash, .api, .wire, .persist]
    static var `default`: DSONOutput = .all
}

// MARK: - Preset Inverse OptionSets
public extension DSONOutput {
    static let allButHash = DSONOutput.all.removing(.hash)
}

public extension DSONOutput {
    func allowsOutput(of other: DSONOutput) -> Bool {
        print("Self: \(self)")
        print("allowsOutput(of: \(other)")
        return isIntersecting(other)
    }
}

// MARK: - CustomStringConvertible
public extension DSONOutput {
    var description: String {
        switch self {
        case .none: return "None ([])"
        case .hash: return "[.hash]"
        case .api: return "[.api]"
        case .wire: return "[.wire]"
        case .persist: return "[.persist]"
        case .all: return "All (default)"
        case .allButHash: return "[.api, .wire, .persist] (All but hash)"
        default:
            let containsHash = contains(.hash)
            let containsApi = contains(.api)
            let containsWire = contains(.wire)
            let containsPersist = contains(.persist)
            return "[hash: \(containsHash), api: \(containsApi), wire: \(containsWire), persist: \(containsPersist)]"
        }
    }
}

public extension OptionSet {
    func removing(_ member: Self.Element) -> Self {
        var copy = self
        copy.remove(member)
        return copy
    }
}
