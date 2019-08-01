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
