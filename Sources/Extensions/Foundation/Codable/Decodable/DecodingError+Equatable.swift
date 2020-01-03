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

extension DecodingError: Equatable {
    
    public static func == (lhs: DecodingError, rhs: DecodingError) -> Bool {
        
        switch (lhs, rhs) {

            /// `typeMismatch` is an indication that a value of the given type could not
            /// be decoded because it did not match the type of what was found in the
            /// encoded payload. As associated values, this case contains the attempted
            /// type and context for debugging.
        case (
            .typeMismatch(let lhsType, let lhsContext),
            .typeMismatch(let rhsType, let rhsContext)):
            return lhsType == rhsType && lhsContext == rhsContext
            
            /// `valueNotFound` is an indication that a non-optional value of the given
            /// type was expected, but a null value was found. As associated values,
            /// this case contains the attempted type and context for debugging.
        case (
            .valueNotFound(let lhsType, let lhsContext),
            .valueNotFound(let rhsType, let rhsContext)):
            return lhsType == rhsType && lhsContext == rhsContext
            
            /// `keyNotFound` is an indication that a keyed decoding container was asked
            /// for an entry for the given key, but did not contain one. As associated values,
            /// this case contains the attempted key and context for debugging.
        case (
            .keyNotFound(let lhsKey, let lhsContext),
            .keyNotFound(let rhsKey, let rhsContext)):
            return lhsKey.stringValue == rhsKey.stringValue && lhsContext == rhsContext
            
            /// `dataCorrupted` is an indication that the data is corrupted or otherwise
            /// invalid. As an associated value, this case contains the context for debugging.
        case (
            .dataCorrupted(let lhsContext),
            .dataCorrupted(let rhsContext)):
            return lhsContext == rhsContext
            
        default: return false
        }
    }
}

extension DecodingError.Context: Equatable {
    public static func == (lhs: DecodingError.Context, rhs: DecodingError.Context) -> Bool {
        return lhs.debugDescription == rhs.debugDescription
    }
}
