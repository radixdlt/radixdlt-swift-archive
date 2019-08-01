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

public struct SignableMessage:
    Signable,
    ExactLengthSpecifying,
    StringInitializable,
    DataInitializable,
    DataConvertible
{
    // swiftlint:enable colon opening_brace
    
    public static let length: Int = 32
    
    private let unsignedData: Data
    
    public init(data unsignedData: Data) throws {
        try SignableMessage.validateLength(of: unsignedData)
        self.unsignedData = unsignedData
    }
    
    public init(unhashed dataConvertible: DataConvertible, hashedBy hasher: Hashing = RadixHasher()) throws {
        let unhashed = dataConvertible.asData
        let hashed = hasher.hash(data: unhashed)
        try self.init(data: hashed)
    }
}

public extension SignableMessage {
    init(string: String, encoding: String.Encoding) throws {
        try self.init(data: string.toData(encodingForced: encoding))
    }
    
    init(hash: RadixHash) {
        do {
            try self.init(data: hash.asData)
        } catch {
            incorrectImplementation("Should work")
        }
    }
}

// MARK: - StringInitializable
public extension SignableMessage {
    init(string: String) throws {
        try self.init(string: string, encoding: .default)
    }
    
    enum Error: Swift.Error {
        case failedToEncodeMessage(encoding: String.Encoding)
    }
}

// MARK: - Signable
public extension SignableMessage {
    var signableData: Data {
        return unsignedData
    }
}

// MARK: - DataConvertible
public extension SignableMessage {
    var asData: Data {
        return unsignedData
    }
}
