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

// swiftlint:disable colon

/// Small container used for JSON encoding/decoding. The JSON received
/// from the Radix API contains type encoded as strings with some prefix, giving information to the Decoder on how it should be decoded. An example of such a string fetched from the API is:
/// ":adr:JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor", which is how addresses are sent.
/// This type holds the Swift enum type translated from ":adr: into JSONPrefix.addressBase58 and
/// the value "JH1P8f3znbyrDj8F4RWpix7hRkgxqHjdW2fNnKpR3v6ufXnknor", being a string that should be decoded into a Base58String type.
///
/// - seeAlso:
/// `JSONPrefix`
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/56557727/DSON+Encoding
///
public struct PrefixedStringWithValue:
    StringRepresentable,
    Decodable {
// swiftlint:enable colon

    public let stringValue: String
    public let jsonPrefix: JSONPrefix
    
    public init(string: String) throws {
        var prefix: JSONPrefix?
        for jsonPrefix in JSONPrefix.allCases {
            guard string.contains(jsonPrefix.identifier) else { continue }
            prefix = jsonPrefix
            break
        }
        guard let jsonPrefix = prefix, let range = string.range(of: jsonPrefix.identifier) else {
            throw Error.noPrefixFound
        }
        guard range.lowerBound == string.startIndex else {
            throw Error.noPrefixFoundAtStart
        }
        let value = string.removingSubrange(range)
        guard !value.isEmpty else {
            throw Error.noValueFound
        }
        self.jsonPrefix = jsonPrefix
        self.stringValue = value
    }
    
    public init(value: String, prefix: JSONPrefix) {
        self.stringValue = value
        self.jsonPrefix = prefix
    }
}

public extension PrefixedStringWithValue {
    var identifer: String {
        return [
            jsonPrefix.identifier,
            String(describing: stringValue)
        ].joined()
    }
}

// MARK: - Error
public extension PrefixedStringWithValue {
    enum Error: Swift.Error, Equatable {
        case noPrefixFoundAtStart
        case noPrefixFound
        case noValueFound
        case prefixMismatch(expected: JSONPrefix, butGot: JSONPrefix)

    }
}

// MARK: - Decodable
public extension PrefixedStringWithValue {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawString = try container.decode(String.self)
        try self.init(string: rawString)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(identifer)
    }
}

// MARK: - CustomStringConvertible
public extension PrefixedStringWithValue {
    var description: String {
        return identifer
    }
}
