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

public protocol TokenMinting {
    
    /// Mints new tokens of the TokenDefinition kind
    func mintTokens(action mintTokensAction: MintTokensAction) -> PendingTransaction
}

public extension TokenMinting {
    func mintTokens(
        amount: PositiveAmount,
        ofType tokenDefinitionReference: ResourceIdentifier,
        minter: AddressConvertible,
        credit creditSomeoneElseThanMinter: AddressConvertible? = nil
    ) -> PendingTransaction {
    
        let creditNewlyMintedTokensTo = creditSomeoneElseThanMinter ?? minter
        
        let mintAction = MintTokensAction(
            tokenDefinitionReference: tokenDefinitionReference,
            amount: amount,
            minter: minter.address,
            creditNewlyMintedTokensTo: creditNewlyMintedTokensTo.address
        )
        
        return mintTokens(action: mintAction)
    }
}

public extension TokenMinting where Self: ActiveAccountOwner {
    func mintTokens(
        amount: PositiveAmount,
        ofType tokenDefinitionReference: ResourceIdentifier,
        credit creditSomeoneElseThanMinter: AddressConvertible? = nil
    ) -> PendingTransaction {
        
        return mintTokens( 
            amount: amount,
            ofType: tokenDefinitionReference,
            minter: addressOfActiveAccount,
            credit: creditSomeoneElseThanMinter
        )
    }
}
