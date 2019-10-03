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

internal extension UnallocatedTokensParticle {
    
    enum Error: Swift.Error, Equatable {
        case tokenPermissionsAreRequired
    }
    
    init(
        mutableSupplyTokenDefinitionParticle: MutableSupplyTokenDefinitionParticle,
        positiveSupply: PositiveSupply
        ) {
        
        self.init(
            amount: Supply(subset: positiveSupply),
            tokenDefinitionReference: mutableSupplyTokenDefinitionParticle.tokenDefinitionReference,
            permissions: mutableSupplyTokenDefinitionParticle.permissions,
            granularity: mutableSupplyTokenDefinitionParticle.granularity
        )
    }
    
    init(
        unallocatedTokensParticle: UnallocatedTokensParticle,
        amount: Supply
    ) {
        
        self.init(
            amount: amount,
            tokenDefinitionReference: unallocatedTokensParticle.tokenDefinitionReference,
            permissions: unallocatedTokensParticle.permissions,
            granularity: unallocatedTokensParticle.granularity
        )
    }
    
    init(
        unallocatedTokensParticle: UnallocatedTokensParticle,
        amount nonNegativeAmount: NonNegativeAmount
    ) throws {
        
        let amount = try Supply(unrelated: nonNegativeAmount)
    
        self.init(
            unallocatedTokensParticle:
            unallocatedTokensParticle,
            amount: amount
        )
    }
    
    init(
        transferrableTokensParticle: TransferrableTokensParticle,
        amount: Supply
    ) throws {
        
        guard let permissions = transferrableTokensParticle.permissions else {
            throw Error.tokenPermissionsAreRequired
        }
        
        self.init(
            amount: amount,
            tokenDefinitionReference: transferrableTokensParticle.tokenDefinitionReference,
            permissions: permissions,
            granularity: transferrableTokensParticle.granularity
        )
    }
    
    init(
        transferrableTokensParticle: TransferrableTokensParticle,
        amount nonNegativeAmount: NonNegativeAmount
    ) throws {
        
        let amount = try Supply(unrelated: nonNegativeAmount)
        
        try self.init(
            transferrableTokensParticle: transferrableTokensParticle,
            amount: amount
        )
    }
}

public extension UnallocatedTokensParticle {
    static func maxSupplyForNewToken(mutableSupplyTokenDefinitionParticle: MutableSupplyTokenDefinitionParticle) -> UnallocatedTokensParticle {
        return UnallocatedTokensParticle(
            mutableSupplyTokenDefinitionParticle: mutableSupplyTokenDefinitionParticle,
            positiveSupply: .max
        )
    }
}
