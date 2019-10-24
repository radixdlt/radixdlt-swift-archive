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

/// A MetaData type that enforces the occurence of one key-value pair for `timestamp`
public struct ChronoMetaData:
    MetaDataConvertible,
    ValueValidating
{
    // swiftlint:enable colon opening_brace
    public let dictionary: [MetaDataKey: String]
    
    public init(validate unvalidated: Map) throws {
        let validated = try ChronoMetaData.validate(unvalidated)
        self.dictionary = validated
    }
    
    public init(dictionary unvalidated: Map) {
        do {
            let validated = try ChronoMetaData.validate(unvalidated)
            self.dictionary = validated
        } catch {
            incorrectImplementation("Invalid Map, error: \(error)")
        }
    }
}

// MARK: Validation
public extension ChronoMetaData {
    enum Error: Swift.Error {
        case noTimestampString
        case invalidTimestampString
    }
    
    static func validate(_ map: Map) throws -> Map {
        guard let timestampString = map[.timestamp] else {
            throw Error.noTimestampString
        }
        guard TimeConverter.dateFrom(string: timestampString) != nil else {
            throw Error.invalidTimestampString
        }
        return map
    }
}
