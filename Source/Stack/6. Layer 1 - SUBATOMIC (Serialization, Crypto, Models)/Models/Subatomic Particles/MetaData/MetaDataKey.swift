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

/// Open enum
public struct MetaDataKey:
    PrefixedJsonCodable,
    StringInitializable,
    StringRepresentable,
    Hashable,
    CustomStringConvertible {

// swiftlint:enable colon

    public let key: String
    
    public init(_ key: String) {
        self.key = key
    }
}

// MARK: - StringInitializable
public extension MetaDataKey {
    init(string: String) throws {
        self.init(string)
    }
}

// MARK: - StringRepresentable
public extension MetaDataKey {
    var stringValue: String {
        return key
    }
}

// MARK: - CustomStringConvertible
public extension MetaDataKey {
    var description: String {
        return key
    }
}

// MARK: - Presets
public extension MetaDataKey {
    static let timestamp: MetaDataKey   = "timestamp"
    static let proofOfWork: MetaDataKey = "powNonce"
    static let application: MetaDataKey = "application"
    static let contentType: MetaDataKey = "contentType"
    static let encrypted: MetaDataKey = "encrypted"
    static let attachment: MetaDataKey = "attachement"
}
