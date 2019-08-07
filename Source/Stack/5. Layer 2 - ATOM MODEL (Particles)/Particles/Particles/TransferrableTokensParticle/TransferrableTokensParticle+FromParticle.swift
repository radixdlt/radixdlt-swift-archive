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

internal extension TransferrableTokensParticle {
    init(
        mutableSupplyTokenDefinitionParticle: MutableSupplyTokenDefinitionParticle,
        amount: PositiveAmount
    ) throws {
        
        try self.init(
            amount: amount,
            address: mutableSupplyTokenDefinitionParticle.address,
            tokenDefinitionReference: mutableSupplyTokenDefinitionParticle.tokenDefinitionReference,
            permissions: mutableSupplyTokenDefinitionParticle.permissions,
            granularity: mutableSupplyTokenDefinitionParticle.granularity
        )
    }
    
    init(
        fixedSupplyTokenDefinitionParticle: FixedSupplyTokenDefinitionParticle,
        positiveSupply: PositiveSupply
    ) throws {
    
        try self.init(
            amount: positiveSupply.amount,
            address: fixedSupplyTokenDefinitionParticle.address,
            tokenDefinitionReference: fixedSupplyTokenDefinitionParticle.tokenDefinitionReference,
            permissions: nil,
            granularity: fixedSupplyTokenDefinitionParticle.granularity
        )
    }
    
    init(
        transferrableTokensParticle: TransferrableTokensParticle,
        amount: PositiveAmount,
        address: Address
    ) throws {
        
        try self.init(
            amount: amount,
            address: address,
            tokenDefinitionReference: transferrableTokensParticle.tokenDefinitionReference,
            permissions: transferrableTokensParticle.permissions,
            granularity: transferrableTokensParticle.granularity
        )
    }
    
    init(
        transferrableTokensParticle: TransferrableTokensParticle,
        amount nonNegativeAmount: NonNegativeAmount,
        address: Address
    ) throws {
        
        let positiveAmount = try PositiveAmount(nonNegative: nonNegativeAmount)
        
        try self.init(
            transferrableTokensParticle: transferrableTokensParticle,
            amount: positiveAmount,
            address: address
        )
    }
    
    init(
        transferrableTokensParticle: TransferrableTokensParticle,
        amount: PositiveAmount
    ) throws {
        
        try self.init(
            amount: amount,
            address: transferrableTokensParticle.address,
            tokenDefinitionReference: transferrableTokensParticle.tokenDefinitionReference,
            permissions: transferrableTokensParticle.permissions,
            granularity: transferrableTokensParticle.granularity
        )
    }
    
    init(
        transferrableTokensParticle: TransferrableTokensParticle,
        amount nonNegativeAmount: NonNegativeAmount
    ) throws {
        
        let positiveAmount = try PositiveAmount(nonNegative: nonNegativeAmount)
        
        try self.init(
            transferrableTokensParticle: transferrableTokensParticle,
            amount: positiveAmount
        )
    }
    
    init(
        unallocatedTokensParticle: UnallocatedTokensParticle,
        amount: PositiveAmount,
        address: Address
    ) throws {
        
        try self.init(
            amount: amount,
            address: address,
            tokenDefinitionReference: unallocatedTokensParticle.tokenDefinitionReference,
            permissions: unallocatedTokensParticle.permissions,
            granularity: unallocatedTokensParticle.granularity
        )
    }
    
    init(
        unallocatedTokensParticle: UnallocatedTokensParticle,
        amount: NonNegativeAmount,
        address: Address
    ) throws {
        
        let positiveAmount = try PositiveAmount(nonNegative: amount)
        
        try self.init(
            unallocatedTokensParticle: unallocatedTokensParticle,
            amount: positiveAmount,
            address: address
        )
    }
}
