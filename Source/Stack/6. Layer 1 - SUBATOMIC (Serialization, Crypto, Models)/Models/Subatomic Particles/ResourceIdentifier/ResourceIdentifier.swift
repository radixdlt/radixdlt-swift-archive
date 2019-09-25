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

// swiftlint:disable colon opening_brace

/// A Radix resource identifier is a human readable index into the Ledger which points to a name state machine
///
/// On format: `/:address/:name`, e.g.:
/// `"/JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor/XRD"`
public struct ResourceIdentifier:
    PrefixedJSONCodable,
    StringRepresentable,
    DSONPrefixedDataConvertible,
    Hashable,
    CustomStringConvertible
{
  
// swiftlint:enable colon opening_brace

    public let address: Address
    public let name: String
    
    public init(address: Address, name: String) {
        self.address = address
        self.name = name
    }
}

// MARK: - Initialisers
public extension ResourceIdentifier {
    init(address: Address, symbol: Symbol) {
        self.init(address: address, name: symbol.value)
    }
}

// MARK: - DSONPrefixSpecifying
public extension ResourceIdentifier {
    var dsonPrefix: DSONPrefix {
        return .radixResourceIdentifier
    }
}

// MARK: - DSONPrefixedDataConvertible
public extension ResourceIdentifier {
    var cborEncodedData: Data {
        return identifier.toData()
    }
}

// MARK: - StringRepresentable
public extension ResourceIdentifier {
    var stringValue: String {
        return identifier
    }
}

// MARK: - CustomStringConvertible
public extension ResourceIdentifier {
    var description: String {
        return "⁄\(address.short)⁄\(name)"
    }
}

// MARK: - StringInitializable
public extension ResourceIdentifier {
    init(string: String) throws {
        let components = string.components(separatedBy: ResourceIdentifier.separator)
        let componentCount = components.count - 1 // ignoring the empty string
        guard componentCount == ResourceIdentifier.componentCount else {
            throw Error.incorrectComponentCount(expected: ResourceIdentifier.componentCount, butGot: componentCount)
        }
        guard components[0].isEmpty else {
            throw Error.unexpectedLeadingPath
        }
        guard case let addressPath = components[ResourceIdentifier.Index.address.rawValue], !addressPath.isEmpty else {
            throw Error.addressPathIsEmpty
        }

        guard case let namePath = components[ResourceIdentifier.Index.name.rawValue], !namePath.isEmpty else {
            throw Error.namePathEmpty
        }
        
        do {
            self.init(address: try Address(string: addressPath), name: namePath)
        } catch let addressError as Address.Error {
            throw Error.badAddress(error: addressError)
        }
    }
}

// MARK: - Private
private extension ResourceIdentifier {
    /// Expect the string: "/address/name", with two separator, to result in these three components: [<ADDRESS>, <NAME/SYMBOL>], not counting the actual first component being the empty string
    static let componentCount = Index.allCases.count
    static let separator = "/"
    enum Index: Int, CaseIterable {
        case address = 1
        case name
    }
}

// MARK: - Error
public extension ResourceIdentifier {
    enum Error: Swift.Error, Equatable {
        case incorrectComponentCount(expected: Int, butGot: Int)
        case unexpectedLeadingPath
        case addressPathIsEmpty
        case namePathEmpty
        case badAddress(error: Address.Error)
    }
}

// MARK: - PrefixedJSONDecodable
public extension ResourceIdentifier {
    static let jsonPrefix: JSONPrefix = .uri
}

// MARK: - Public
public extension ResourceIdentifier {
    var identifier: String {
        return [
            "",
            address.base58String.value,
            name
        ].joined(separator: ResourceIdentifier.separator)
    }
}
