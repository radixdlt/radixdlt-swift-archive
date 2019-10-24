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

public struct TokenBalance: Equatable, Throwing {
    public let token: TokenDefinition
    public let amount: NonNegativeAmount
    public let owner: Address
    
    public init(token tokenConvertible: TokenConvertible, amount: NonNegativeAmount, owner: AddressConvertible) {
        self.token = TokenDefinition(tokenConvertible: tokenConvertible)
        self.amount = amount
        self.owner = owner.address
    }
}

public extension TokenBalance {
    
    enum Error: Swift.Error, Equatable {
        case tokenDefinitionReferenceMismatch
        case transferrableTokens
    }
    
    init(tokenDefinition: TokenConvertible, tokenReferenceBalance: TokenReferenceBalance) throws {
        if tokenDefinition.tokenDefinitionReference != tokenReferenceBalance.tokenResourceIdentifier {
            throw Error.tokenDefinitionReferenceMismatch
        }
        
        self.init(
            token: tokenDefinition,
            amount: tokenReferenceBalance.amount,
            owner: tokenReferenceBalance.owner
        )
    }
    
    static func zero(token: TokenDefinition, ownedBy owner: AddressConvertible) -> TokenBalance {
        return TokenBalance(token: token, amount: .zero, owner: owner)
    }
}
