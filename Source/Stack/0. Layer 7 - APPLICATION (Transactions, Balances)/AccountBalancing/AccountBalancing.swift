//
//  AccountBalancing.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

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
