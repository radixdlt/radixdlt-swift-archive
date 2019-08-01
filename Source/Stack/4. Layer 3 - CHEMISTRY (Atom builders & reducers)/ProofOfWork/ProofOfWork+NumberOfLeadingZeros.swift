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

public extension ProofOfWork {
    struct NumberOfLeadingZeros: ExpressibleByIntegerLiteral {
        
        public let numberOfLeadingZeros: Value
        
        init(_ numberOfLeadingZeros: Value) throws {
            
            guard numberOfLeadingZeros >= NumberOfLeadingZeros.minimumNumberOfLeadingZeros else {
                throw Error.tooFewLeadingZeros(
                    expectedAtLeast: NumberOfLeadingZeros.minimumNumberOfLeadingZeros,
                    butGot: numberOfLeadingZeros
                )
            }
            
            self.numberOfLeadingZeros = numberOfLeadingZeros
        }
    }
}

// MARK: - Presets
public extension ProofOfWork.NumberOfLeadingZeros {
    static let minimumNumberOfLeadingZeros: Value = 1

    static let `default`: ProofOfWork.NumberOfLeadingZeros = 16
}

// MARK: - Errors
public extension ProofOfWork.NumberOfLeadingZeros {
    typealias Value = UInt8
    
    enum Error: Swift.Error {
        case tooFewLeadingZeros(expectedAtLeast: Value, butGot: Value)
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension ProofOfWork.NumberOfLeadingZeros {
    init(integerLiteral value: Value) {
        do {
            try self.init(value)
        } catch {
            fatalError("Bad value, error: \(error)")
        }
    }
}

// MARK: Data + NumberOfLeadingZeroBits
internal extension DataConvertible {
    var numberOfLeadingZeroBits: Int {
        let byteArray = self.bytes
        let bitsPerByte = Int.bitsPerByte
        guard let index = byteArray.firstIndex(where: { $0 != 0 }) else {
            return byteArray.count * bitsPerByte
        }
        
        // count zero bits in byte at index `index`
        return index * bitsPerByte + byteArray[index].leadingZeroBitCount
    }
}

internal extension ProofOfWork.NumberOfLeadingZeros {
    static func < (lhs: Int, rhs: ProofOfWork.NumberOfLeadingZeros) -> Bool {
        return lhs < rhs.numberOfLeadingZeros
    }
    
    static func >= (lhs: Int, rhs: ProofOfWork.NumberOfLeadingZeros) -> Bool {
        return lhs >= rhs.numberOfLeadingZeros
    }
}

