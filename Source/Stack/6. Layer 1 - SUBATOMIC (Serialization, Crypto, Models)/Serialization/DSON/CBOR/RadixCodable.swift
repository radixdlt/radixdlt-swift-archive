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

let jsonKeyVersion = "version"
let serializerVersion = 100

let jsonKeyDestinations = "destinations"

public protocol RadixCodable: EncodableKeyValueListConvertible, AnyEncodableKeyValueListConvertible, AnyEncodableKeyValuesProcessing {}

public extension RadixCodable {
    
    var preProcess: Process {
        return { keyValues, output in
            var keyValues = keyValues
            keyValues.append(try AnyEncodableKeyValue(key: jsonKeyVersion, encodable: serializerVersion, output: .all))
            
            if let modelTypeSpecyfing = self as? RadixModelTypeStaticSpecifying {
                keyValues.append(try AnyEncodableKeyValue(key: RadixModelType.jsonKey, encodable: modelTypeSpecyfing.serializer.serializerId, output: .all))
            }
            
            // this is the first "common" JSON property, "common" as in property shared by all Particle types. Move this to some place where we can nicely
            // handle future propertys.
            if let destinationsOwner = self as? DestinationsOwner {
                // For now we only need to encode (and not also decode) "destination", no need to decode it, since it is a computed property.
                keyValues.append(try AnyEncodableKeyValue(key: jsonKeyDestinations, encodable: destinationsOwner.destinations(), output: .all))
            }
            
            return keyValues
        }
    }
}

