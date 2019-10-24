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

public protocol EncodableKeyValueListConvertible {
    associatedtype CodingKeys: CodingKey
    func encodableKeyValues() throws -> [EncodableKeyValue<CodingKeys>]
}

// MARK: - Swift.Encodable (JSON)
public extension Encodable where Self: EncodableKeyValueListConvertible {
    func encode(to encoder: Encoder) throws {
        guard let serializerValueCodingKey = CodingKeys(stringValue: RadixModelType.jsonKey) else {
            incorrectImplementation("You MUST declare a CodingKey having the string value `\(RadixModelType.jsonKey)` in your encodable model.")
        }
        
        guard let serializerVersionCodingKey = CodingKeys(stringValue: jsonKeyVersion) else {
            incorrectImplementation("You MUST declare a CodingKey having the string value `\(jsonKeyVersion)` in your encodable model.")
        }
        
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(serializerVersion, forKey: serializerVersionCodingKey)
        
        if let modelTypeSpecifying = self as? RadixModelTypeStaticSpecifying {
            try container.encode(modelTypeSpecifying.serializer, forKey: serializerValueCodingKey)
        }
        
        if let destinationsOwner = self as? DestinationsOwner {
            guard let destinationsCodingKey = CodingKeys(stringValue: jsonKeyDestinations) else {
                incorrectImplementation("You MUST declare a CodingKey having the string value `\(jsonKeyDestinations)` in your encodable model.")
            }
            try container.encode(destinationsOwner.destinations(), forKey: destinationsCodingKey)
        }
        
        try encodableKeyValues().forEach {
            try $0.jsonEncoded(by: &container)
        }
    }
}
