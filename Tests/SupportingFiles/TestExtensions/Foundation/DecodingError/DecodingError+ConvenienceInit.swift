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

extension DecodingError {
    
    static var expectedStringButGotDictionary: DecodingError {
        return DecodingError.expectedType(String.self, "Expected to decode String but found a dictionary instead.")
    }
    
    static func keyNotFound<C>(_ key: C) -> DecodingError where C: CodingKey {
        let ignoredContext = DecodingError.Context(codingPath: [], debugDescription: "")
        return DecodingError.keyNotFound(key, ignoredContext)
    }
    
    static func expectedType<T>(_ type: T.Type, _ description: String) -> DecodingError {
        return DecodingError.typeMismatch(type, DecodingError.Context(codingPath: [], debugDescription: description))
    }
    
    static var invalidJSON: DecodingError {
        return DecodingError.dataCorrupted(description: "The given data was not valid JSON.")
    }
    
    static func dataCorrupted(description: String) -> DecodingError {
        return DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: description))
    }
}
