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

public typealias JSON = [String: Any]

public final class RadixJSONDecoder: Foundation.JSONDecoder {
    public func decodeRadix<T>(_ type: T.Type, from data: Data) throws -> T where T: Decodable & RadixModelTypeStaticSpecifying {
        let jsonObjectAny = try JSONSerialization.jsonObject(with: data, options: [])
        
        func handle(jsonObject: JSON) throws {
            guard let modelTypeString = jsonObject[RadixModelType.jsonKey] as? String else {
                throw AtomModelDecodingError.noSerializer(in: jsonObject)
            }
            let modelType = try RadixModelType(serializerId: modelTypeString)
            guard modelType == T.serializer else {
                throw AtomModelDecodingError.jsonDecodingErrorTypeMismatch(expectedSerializer: T.serializer, butGot: modelType)
            }
        }
        
        if let json = jsonObjectAny as? JSON {
            try handle(jsonObject: json)
        } else if let jsonArray = jsonObjectAny as? [JSON] {
            try jsonArray.forEach { try handle(jsonObject: $0) }
        } else {
            incorrectImplementation("Forgot some case..., got jsonObjectAny: <\(jsonObjectAny)>")
        }

        return try super.decode(type, from: data)
    }
    
}
