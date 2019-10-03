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

public extension BigInteger {
    
    func toHexString(uppercased: Bool = true) -> HexString {
        let string = toString(uppercased: uppercased, radix: 16)
        do {
            return try HexString(string: string)
        } catch {
            incorrectImplementationShouldAlwaysBeAble(to: "Create `HexString`", error)
        }
    }
    
    func toDecimalString() -> String {
        return toString(radix: 10)
    }
    
    func toString(uppercased: Bool = true, radix: Int) -> String {
        let stringRepresentation = String(self, radix: radix)
        guard uppercased else { return stringRepresentation }
        return stringRepresentation.uppercased()
    }
}

extension Data: DataConvertible {
    
    public var asData: Data {
        return self
    }
}

func * <I>(lhs: I, rhs: I?) -> I? where I: BinaryInteger {
    guard let rhs = rhs else {
        return nil
    }
    return lhs * rhs
}

public enum ConcatMode {
    case prepend
    case append
}

extension String {
    func append(character: Character, toLength expectedLength: Int?) -> String {
        return prependingOrAppending(character: character, toLength: expectedLength, mode: .append)
    }
    
    func prepending(character: Character, toLength expectedLength: Int?) -> String {
        return prependingOrAppending(character: character, toLength: expectedLength, mode: .prepend)
    }
    
    mutating func prependOrAppend(character: Character, toLength expectedLength: Int?, mode: ConcatMode) {
        self = prependingOrAppending(character: character, toLength: expectedLength, mode: mode)
    }
    
    func prependingOrAppending(character: Character, toLength expectedLength: Int?, mode: ConcatMode) -> String {
        guard let expectedLength = expectedLength else {
            return self
        }
        var modified = self
        let new = String(character)
        while modified.length < expectedLength {
            switch mode {
            case .prepend: modified = new + modified
            case .append: modified += new
            }
   
        }
        return modified
    }
}
