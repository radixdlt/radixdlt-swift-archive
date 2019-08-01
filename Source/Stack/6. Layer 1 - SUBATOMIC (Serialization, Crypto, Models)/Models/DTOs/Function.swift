/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation

public struct Function<Argument, Return> {
    
    private let _apply: (Argument) -> Return
    
    public init(_ apply: @escaping (Argument) -> Return) {
        self._apply = apply
    }
}

public extension Function {
    func apply(_ argument: Argument) -> Return {
        return self._apply(argument)
    }
}

public struct BiFunction<Argument0, Argument1, Return> {
    
    private let _apply: (Argument0, Argument1) -> Return
    
    public init(_ apply: @escaping (Argument0, Argument1) -> Return) {
        self._apply = apply
    }
}

public extension BiFunction {
    func apply(_ argument0: Argument0, _ argument1: Argument1) -> Return {
        return self._apply(argument0, argument1)
    }
}
