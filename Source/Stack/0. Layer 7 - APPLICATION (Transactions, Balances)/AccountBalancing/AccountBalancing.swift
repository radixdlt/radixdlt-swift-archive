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
        
    func observeBalances(at address: Address) -> Observable<TokenBalances>
    func observeBalance(of tokenIdentifier: ResourceIdentifier, for address: Address) -> Observable<TokenBalance?>
}

public extension AccountBalancing {
    
    var nativeTokenIdentifier: ResourceIdentifier {
        return nativeTokenDefinition.tokenDefinitionReference
    }
    
    func observeBalance(of tokenIdentifier: ResourceIdentifier, for address: Address) -> Observable<TokenBalance?> {
        return observeBalances(at: address).map {
            $0.balance(of: tokenIdentifier)
        }
    }
    
    func observeMyBalances() -> Observable<TokenBalances> {
        return observeBalances(at: addressOfActiveAccount)
    }
    
    func observeMyBalance(of tokenIdentifier: ResourceIdentifier) -> Observable<TokenBalance?> {
        return observeBalance(of: tokenIdentifier, for: addressOfActiveAccount)
    }
    
    func observeMyBalanceOfNativeTokens() -> Observable<TokenBalance?> {
        return observeMyBalance(of: nativeTokenIdentifier)
    }
    
    func observeMyBalanceOfNativeTokensOrZero() -> Observable<TokenBalance> {
        return observeMyBalanceOfNativeTokens()
            .replaceNilWith(TokenBalance.zero(token: nativeTokenDefinition, ownedBy: addressOfActiveAccount))
    }
    
    func balanceOfNativeTokensOrZero(for address: Address) -> Observable<TokenBalance> {
        return observeBalance(of: nativeTokenIdentifier, for: address)
            .replaceNilWith(TokenBalance.zero(token: nativeTokenDefinition, ownedBy: address))
    }
}
