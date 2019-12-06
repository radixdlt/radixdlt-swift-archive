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

public protocol DataConvertible: LengthMeasurable {
    var asData: Data { get }
    var bytes: [Byte] { get }
    func toData(minByteCount: Int?, concatMode: ConcatMode) -> Data
    func toHexString(case: String.Case?, mode: StringConversionMode?) -> HexString
    func toBase64String(minLength: Int?) -> Base64String
    func toBase58String(minLength: Int?) -> Base58String
}

// MARK: - Default Implementation
public extension DataConvertible {
    func toData(minByteCount expectedLength: Int? = nil, concatMode: ConcatMode = .prepend) -> Data {
        
        guard let expectedLength = expectedLength else {
            return self.asData
        }
        var modified: Data = self.asData
        let new = Byte(0x0)
        while modified.length < expectedLength {
            switch concatMode {
            case .prepend: modified = new + modified
            case .append: modified = modified + new
            }
        }
        return modified
        
    }
    
    var bytes: [Byte] { asData.bytes }
}

// MARK: - LengthMeasurable
public extension DataConvertible {
    var length: Int {
        return asData.bytes.count
    }
}

// MARK: - Integer
public extension DataConvertible {
    var unsignedBigInteger: BigUnsignedInt {
        return BigUnsignedInt(asData)
    }
}

// MARK: - Conformance
extension Array: DataConvertible where Element == Byte {
    public var asData: Data {
        Data(self)
    }
    
    public var bytes: [Byte] {
        self
    }
}

extension Data {
    public var bytes: [Byte] {
        [Byte](self)
    }
}

extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    
    func toHexString(options: HexEncodingOptions = []) -> String {
        let hexDigits = Array((options.contains(.upperCase) ? "0123456789ABCDEF" : "0123456789abcdef").utf16)
        var chars: [unichar] = []
        chars.reserveCapacity(2 * count)
        for byte in self {
            chars.append(hexDigits[Int(byte / 16)])
            chars.append(hexDigits[Int(byte % 16)])
        }
        return String(utf16CodeUnits: chars, count: chars.count)
    }
}

extension Array where Element == Byte {
    
    // swiftlint:disable identifier_name
    
    // https://github.com/krzyzanowskim/CryptoSwift/blob/1755bd0917f401451d16faafe3c8e078b8eeb9c9/Sources/CryptoSwift/Array%2BExtension.swift#L28-L64
    public init(hex: String) {
        self.init(reserveCapacity: hex.unicodeScalars.lazy.underestimatedCount)
        var buffer: UInt8?
        var skip = hex.hasPrefix("0x") ? 2 : 0
        for char in hex.unicodeScalars.lazy {
            guard skip == 0 else {
                skip -= 1
                continue
            }
            guard char.value >= 48 && char.value <= 102 else {
                removeAll()
                return
            }
            let v: UInt8
            let c: UInt8 = UInt8(char.value)
            switch c {
            case let c where c <= 57:
                v = c - 48
            case let c where c >= 65 && c <= 70:
                v = c - 55
            case let c where c >= 97:
                v = c - 87
            default:
                removeAll()
                return
            }
            if let b = buffer {
                append(b << 4 | v)
                buffer = nil
            } else {
                buffer = v
            }
        }
        if let b = buffer {
            append(b)
        }
    }
    
    // swiftlint:enable identifier_name
    
    init(reserveCapacity: Int) {
        self = [Element]()
        self.reserveCapacity(reserveCapacity)
    }
}
