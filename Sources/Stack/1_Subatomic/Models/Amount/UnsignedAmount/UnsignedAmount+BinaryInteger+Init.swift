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

public extension UnsignedAmount {
    init<T>(truncatingIfNeeded source: T) where T: BinaryInteger {
        let magnitude = Magnitude(truncatingIfNeeded: source)
        
        if magnitude > Bound.greatestFiniteMagnitude {
            self.magnitude = Bound.greatestFiniteMagnitude
        } else if magnitude < Bound.leastNormalMagnitude {
            self.magnitude = Bound.leastNormalMagnitude
        } else {
            self.magnitude = magnitude
        }
    }
    
    init?<T>(exactly source: T) where T: BinaryFloatingPoint {
        guard let magnitude = Magnitude(exactly: source) else { return nil }
        try? self.init(magnitude: magnitude)
    }
    
    /// Creates the least possible amount
    init() {
        self.magnitude = Bound.leastNormalMagnitude
    }
    
    init<T>(_ source: T) where T: BinaryInteger {
        let magnitude = Magnitude(source)
        do {
            try self.init(magnitude: magnitude)
        } catch {
            badLiteralValue(source, error: error)
        }
    }
    
    init<T>(_ source: T) where T: BinaryFloatingPoint {
        let magnitude = Magnitude(source)
        do {
            try self.init(magnitude: magnitude)
        } catch {
            badLiteralValue(source, error: error)
        }
    }
    
    init<T>(clamping source: T) where T: BinaryInteger {
        let magnitude = Magnitude(clamping: source)
        
        if magnitude > Bound.greatestFiniteMagnitude {
            self.magnitude = Bound.greatestFiniteMagnitude
        } else if magnitude < Bound.leastNormalMagnitude {
            self.magnitude = Bound.leastNormalMagnitude
        } else {
            self.magnitude = magnitude
        }
    }
    
    init(integerLiteral value: IntegerLiteralType) {
        let magnitude = Magnitude(integerLiteral: value)
        do {
            try self.init(magnitude: magnitude)
        } catch {
            badLiteralValue(value, error: error)
        }
    }
}
