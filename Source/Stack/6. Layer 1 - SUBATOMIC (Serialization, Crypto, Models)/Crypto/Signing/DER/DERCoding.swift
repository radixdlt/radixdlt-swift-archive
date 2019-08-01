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

// swiftlint:disable all

/// Taken from from: https://gist.github.com/Jugale/2daaec0715d4f6d7347534d42bfa7110
struct DERDecoder {
    
    internal final class SimpleScanner {
        let data: Data
        
        ///The current position of the scanning head
        private(set) var position = 0
        
        init(data: Data) {
            self.data = data
        }
        
        /**
         `true` if there are no more bytes available to scan.
         */
        var isComplete: Bool {
            return position >= data.count
        }
        
        /**
         Roll the scan head back to the position it was at before the last command was run.
         If the last command failed, calling this does nothing as the scan head was already returned to it's state before failure
         */
        func rollback(distance: Int) {
            position -= distance
            
            if position < 0 {
                position = 0
            }
        }
        
        /**
         Scans `d` bytes, or returns `nil` and restores position if `d` is greater than the number of bytes remaining
         */
        func scan(distance: Int) -> Data? {
            return popByte(s: distance)
        }
        
        /**
         Scans to the end of the data.
         */
        func scanToEnd() -> Data? {
            return scan(distance: data.count - position)
        }
        
        private func popByte(s: Int = 1) -> Data? {
            
            guard s > 0 else { return nil }
            guard position <= (data.count - s) else { return nil }
            
            defer {
                position += s
            }
            
            return data.subdata(in: data.startIndex.advanced(by: position)..<data.startIndex.advanced(by: position + s))
        }
    }
    
    struct ASN1Object {
        let type: DERDecoder.DERCode
        let data: Data
    }

    enum DERCode: UInt8 {
        
        //All sequences should begin with this
        //https://en.wikipedia.org/wiki/Abstract_Syntax_Notation_One#Example_encoded_in_DER
        case sequenceCode = 0x30
        
        //Type tags - add more here!
        //http://www.obj-sys.com/asn1tutorial/node10.html
        case boolCode = 0x01
        case integerCode = 0x02
        case ia5StringCode = 0x16
        
        static func allTypes() -> [DERCode] {
            return [
                .boolCode,
                .integerCode,
                .ia5StringCode
            ]
        }
        
        var encodableData: Data {
            return Int(rawValue).evenNumberedBytes
        }
    }
    
    static func decodeData(_ dataConvertible: DataConvertible) -> Data {
        let data = dataConvertible.asData
        guard let integerData = DERDecoder.decode(data: data) else {
            incorrectImplementation("Should get data")
        }
        
        return integerData.reduce(Data(), { (sum, next) -> Data in
            let filter = SimpleScanner(data: next.data)
            if filter.scan(distance: 1)?.firstByte == 0x0 {
                return sum + filter.scanToEnd()!
            } else {
                return sum + next.data
            }
        })
    }
    
  
    private static func decode(data: Data) -> [ASN1Object]? {
        
        let scanner = SimpleScanner(data: data)
        
        //Verify that this is actually a DER sequence
        guard scanner.scan(distance: 1)?.firstByte == DERCode.sequenceCode.rawValue else {
            return nil
        }
        
        //The second byte should equate to the length of the data, minus itself and the sequence type
        guard let expectedLength = scanner.scan(distance: 1)?.firstByte, Int(expectedLength) == data.count - 2 else {
            return nil
        }
        
        var output: [ASN1Object] = []
        
        while !scanner.isComplete {
            
            //Search the current position of the sequence for a known type
            var dataType: DERCode?
            for type in DERCode.allTypes() {
                if scanner.scan(distance: 1)?.firstByte == type.rawValue {
                    dataType = type
                } else {
                    scanner.rollback(distance: 1)
                }
            }
            
            guard let type = dataType else {
                //Unsupported type - add it to `DERCode.all()`
                return nil
            }
            
            guard let length = scanner.scan(distance: 1) else {
                //Expected a byte describing the length of the proceeding data
                return nil
            }
            
            let lengthInt = length.firstByte
            
            guard let actualData = scanner.scan(distance: Int(lengthInt)) else {
                //Expected to be able to scan `lengthInt` bytes
                return nil
            }
            
            let object = ASN1Object(type: type, data: actualData)
            output.append(object)
        }
        
        return output
    }
}

private extension Data {
    var firstByte: Byte { return bytes[0] }
}

extension Int {
    var evenNumberedBytes: Data {
        let hex = String(format: "%02x", self)
        return Data(hex: hex)
    }
}

// swiftlint:enable all
