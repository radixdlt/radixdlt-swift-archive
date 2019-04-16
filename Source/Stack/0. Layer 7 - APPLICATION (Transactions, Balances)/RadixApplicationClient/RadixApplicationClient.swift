//
//  RadixApplicationClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol RadixApplicationClient {
    
    func getBalances(for address: Address) -> Observable<BalancePerToken>
    func makeTransaction(_ transaction: Transaction) -> Completable
    func sendChatMessage(_ message: ChatMessage) -> Completable
}

public extension RadixApplicationClient {
    func getBalances(for address: Address, ofToken token: TokenDefinitionReference) -> Observable<TokenBalance> {
        return getBalances(for: address).map {
            $0.balanceOrZero(of: token, address: address)
        }
    }
}
