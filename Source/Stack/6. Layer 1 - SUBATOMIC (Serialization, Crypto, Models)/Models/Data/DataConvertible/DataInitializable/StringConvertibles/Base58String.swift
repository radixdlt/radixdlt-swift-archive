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

/// String representation of a Base58 string which is impossible to instantiatie with invalid values.
public struct Base58String:
    PrefixedJsonCodable,
    StringConvertible,
    StringRepresentable,
    CharacterSetSpecifying,
    DataConvertible,
    DataInitializable {
// swiftlint:enable colon

    public static var allowedCharacters = CharacterSet.base58
    
    public let value: String
    public init(validated unvalidated: String) {
        do {
            self.value = try Base58String.validate(unvalidated)
        } catch {
            fatalError("Passed unvalid string, error: \(error)")
        }
    }
}

public extension Base58String {
    static let jsonPrefix: JSONPrefix = .addressBase58
}

public extension Data {
    var length: Int {
        return bytes.count
    }
}

// MARK: - DataInitializable
public extension Base58String {
    
    init(data: Data) {
        let bytes: [Byte] = data.bytes
        var x: BigUnsignedInt = data.unsignedBigInteger
        let alphabet: Data = String.base58Alphabet.toData()
        let radix = BigUnsignedInt(alphabet.count)
        
        var answer = [UInt8]()
        answer.reserveCapacity(bytes.count)
        
        while x > 0 {
            let (quotient, modulus) = x.quotientAndRemainder(dividingBy: radix)
            answer.append(alphabet[Int(modulus)])
            x = quotient
        }
        
        let prefix = Array(bytes.prefix(while: {$0 == 0})).map { _ in alphabet[0] }
        answer.append(contentsOf: prefix)
        answer.reverse()
    
        self.init(validated: String(data: answer.asData))
    }
}

// MARK: DataConvertible
public extension Base58String {
    var asData: Data {
    
        let alphabet = String.base58Alphabet.toData()
        let radix = BigUnsignedInt(alphabet.count)
        let byteString = [UInt8](value.utf8)
        
        var answer = BigUnsignedInt(0)
        var temp = BigUnsignedInt(1)
        for character in byteString.reversed() {
            guard let index = alphabet.firstIndex(of: character) else {
                incorrectImplementation("Should contain character")
            }
            answer += temp * BigUnsignedInt(index)
            temp *= radix
        }
        return byteString.prefix(while: { $0 == alphabet[0] }) + answer.serialize()
    }
}

// MARK: - StringRepresentable
public extension Base58String {
    var stringValue: String {
        return value
    }
}
