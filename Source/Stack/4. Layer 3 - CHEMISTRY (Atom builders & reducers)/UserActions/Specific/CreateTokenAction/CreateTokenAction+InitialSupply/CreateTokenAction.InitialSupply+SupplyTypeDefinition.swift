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

public extension CreateTokenAction.InitialSupply {
    enum SupplyTypeDefinition {
        case fixed(to: PositiveSupply)
        case mutable(initial: Supply?)
    }
}

// MARK: Public
public extension CreateTokenAction.InitialSupply.SupplyTypeDefinition {
    var initialSupply: Supply {
        switch self {
        case .fixed(let positiveInitialSupply):
//            return Supply(positiveSupply: positiveInitialSupply)
            return Supply(subset: positiveInitialSupply)
        case .mutable(let nonNegativeInitialSupply):
            return nonNegativeInitialSupply ?? .zero
        }
    }
    
    var tokenSupplyType: SupplyType {
        switch self {
        case .fixed: return .fixed
        case .mutable: return .mutable
        }
    }
    
    func isExactMultipleOfGranularity(_ granularity: Granularity) throws {
        guard initialSupply.isMultiple(of: granularity) else {
            throw CreateTokenAction.Error.initialSupplyNotMultipleOfGranularity
        }
    }
    
    static var mutableZeroSupply: CreateTokenAction.InitialSupply.SupplyTypeDefinition {
        return .mutable(initial: nil)
    }
    
    var isMutable: Bool {
        switch self {
        case .fixed: return false
        case .mutable: return true
        }
    }
    
    var isFixed: Bool {
        switch self {
        case .fixed: return true
        case .mutable: return false
        }
    }
}
