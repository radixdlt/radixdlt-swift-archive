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

// swiftlint:disable colon

/// String representation of a Base64 string which is impossible to instantiatie with invalid values.
public struct Base64String:
    PrefixedJsonCodable,
    StringConvertible,
    StringRepresentable,
    CBORDataConvertible,
    DataInitializable,
    RequiringThatLengthIsMultipleOfN,
    CharacterSetSpecifying {
// swiftlint:enable colon
    
    public static let jsonPrefix: JSONPrefix = .bytesBase64
    
    public static var lengthMultiple = 4
    public static var allowedCharacters =  CharacterSet.base64
    
    public let value: String
    public init(validated unvalidated: String) {
        do {
            self.value = try Base64String.validate(unvalidated)
        } catch {
            fatalError("Passed unvalid string, error: \(error)")
        }
    }
}

// MARK: - DataInitializable
public extension Base64String {
    init(data: Data) {
        self.value = data.base64EncodedString()
    }
}

// MARK: - StringRepresentable
public extension Base64String {
    var stringValue: String {
        return value
    }
}

// MARK: - DataConvertible
public extension Base64String {
    var asData: Data {
        guard let data = Data.init(base64Encoded: value) else {
            incorrectImplementation("Should always be possible to create data from a validated Base64String")
        }
        return data
    }
}
