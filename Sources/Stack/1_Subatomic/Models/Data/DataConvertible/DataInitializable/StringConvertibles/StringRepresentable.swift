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

public protocol LengthMeasurable {
    var length: Int { get }
}

public extension LengthMeasurable {
    
    func nilIfEmpty() -> Self? {
        guard length > 0 else {
            return nil
        }
        return self
    }
}

extension Array: LengthMeasurable {
    public var length: Int { return count }
}

public protocol StringRepresentable: LengthMeasurable {
    var stringValue: String { get }
}

public extension StringRepresentable {
    var length: Int {
        return stringValue.length
    }
}

public extension StringRepresentable where Self: DataConvertible {
    var length: Int {
        return stringValue.length
    }
}

extension String: LengthMeasurable {
    public var length: Int {
        return count
    }
}

public extension StringRepresentable where Self: RawRepresentable, Self.RawValue == String {
    var stringValue: String {
        return rawValue
    }
}

extension String: StringRepresentable {
    public var stringValue: String {
        return self
    }
}

public extension CustomStringConvertible where Self: StringRepresentable {
    var description: String {
        return stringValue
    }
}
