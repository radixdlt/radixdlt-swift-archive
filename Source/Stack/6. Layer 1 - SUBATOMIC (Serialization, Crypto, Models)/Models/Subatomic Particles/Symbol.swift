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

// swiftlint:disable colon opening_brace

/// The "ticker" for a specific Radix Token, e.g. "XRD" for the token named "Rad". Constrained to a specific
/// character set and length, for the formal definition of these constraints read [RIP - Tokens][1].
///
/// - seeAlso:
/// `TokenDefinitionParticle`
///
/// [1]: https://radixdlt.atlassian.net/wiki/spaces/AM/pages/407241467/RIP-2+Tokens
///
public struct Symbol:
    PrefixedJsonCodable,
    CBORStringConvertible,
    CharacterSetSpecifying,
    MinLengthSpecifying,
    MaxLengthSpecifying,
    Hashable
{
// swiftlint:enable colon opening_brace
    
    public static let minLength = 1
    public static let maxLength = 14
    public static let allowedCharacters = CharacterSet.numbersAndUppercaseAtoZ
    
    public let value: String
    
    public init(validated unvalidated: String) {
        do {
            self.value = try Symbol.validate(unvalidated)
        } catch {
            fatalError("Passed unvalid string, error: \(error)")
        }
    }
}

// MARK: - CustomStringConvertible
public extension Symbol {
    var description: String {
        return value.description
    }
}
