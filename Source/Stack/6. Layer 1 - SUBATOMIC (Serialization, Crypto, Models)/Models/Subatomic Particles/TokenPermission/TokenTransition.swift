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

// swiftlint:disable opening_brace

/// Transition of tokens.
public enum TokenTransition: String,
    StringInitializable,
    StringRepresentable,
    Codable,
    Hashable,
    CustomStringConvertible
{
    
    // swiftlint:enable opening_brace

    case mint
    case burn
}

// MARK: - StringInitializable
public extension TokenTransition {
    init(string: String) throws {
        guard let type = TokenTransition(rawValue: string) else {
            throw Error.unsupportedTokenTransition(string)
        }
        self = type
    }
}

// MARK: CustomStringConvertible
public extension TokenTransition {
    var description: String {
        return rawValue
    }
}

// MARK: - Error
public extension TokenTransition {
    enum Error: Swift.Error {
        case unsupportedTokenTransition(String)
    }
}
