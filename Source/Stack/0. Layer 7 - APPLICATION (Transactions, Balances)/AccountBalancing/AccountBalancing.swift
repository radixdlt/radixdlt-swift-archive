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
import RxSwift

public protocol AccountBalancing {
    
    var addressOfActiveAccount: Address { get }
    var nativeTokenDefinition: TokenDefinition { get }
        
    func observeBalances(ownedBy owner: Ownable) -> Observable<TokenBalances>
    func observeBalance(ofToken tokenIdentifier: ResourceIdentifier, ownedBy owner: Ownable) -> Observable<TokenBalance?>
}

public extension AccountBalancing {
    
    var nativeTokenIdentifier: ResourceIdentifier {
        return nativeTokenDefinition.tokenDefinitionReference
    }
    
    func observeBalance(ofToken tokenIdentifier: ResourceIdentifier, ownedBy owner: Ownable) -> Observable<TokenBalance?> {
        return observeBalances(ownedBy: owner).map {
            $0.balance(ofToken: tokenIdentifier)
        }
    }
    
    func observeMyBalances() -> Observable<TokenBalances> {
        return observeBalances(ownedBy: addressOfActiveAccount)
    }
    
    func observeMyBalance(ofToken tokenIdentifier: ResourceIdentifier) -> Observable<TokenBalance?> {
        return observeBalance(ofToken: tokenIdentifier, ownedBy: addressOfActiveAccount)
    }
    
    func observeMyBalanceOfNativeTokens() -> Observable<TokenBalance?> {
        return observeMyBalance(ofToken: nativeTokenIdentifier)
    }
    
    func observeMyBalanceOfNativeTokensOrZero() -> Observable<TokenBalance> {
        return observeMyBalanceOfNativeTokens()
            .replaceNilWith(TokenBalance.zero(token: nativeTokenDefinition, ownedBy: addressOfActiveAccount))
    }
    
    func balanceOfNativeTokensOrZero(ownedBy owner: Ownable) -> Observable<TokenBalance> {
        return observeBalance(ofToken: nativeTokenIdentifier, ownedBy: owner)
            .replaceNilWith(TokenBalance.zero(token: nativeTokenDefinition, ownedBy: owner))
    }
}
