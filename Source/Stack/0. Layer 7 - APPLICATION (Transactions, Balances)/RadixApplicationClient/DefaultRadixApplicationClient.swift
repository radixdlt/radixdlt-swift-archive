//
//  DefaultRadixApplicationClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultRadixApplicationClient: RadixApplicationClient {

    private let nodeInteractor: NodeInteraction
    
    public init(nodeInteractor: NodeInteraction) {
        self.nodeInteractor = nodeInteractor
    }
}

public extension DefaultRadixApplicationClient {
    convenience init(node: Node) {
        self.init(nodeInteractor: DefaultNodeInteraction(node: node))
    }
}

public extension DefaultRadixApplicationClient {
    func getBalances(for address: Address) -> Observable<BalancePerToken> {
        let atomEvents = nodeInteractor.subscribe(to: address)
            .map { $0.update }.filterNil()
            .map { $0.subscriptionUpdate }.filterNil()
            .map { $0.atomEvents }
        return TokenBalanceReducer().reduce(atomEvents: atomEvents)
    }
    
    func makeTransaction(_ transaction: Transaction) -> Completable {
        implementMe
    }
    
    func sendChatMessage(_ message: ChatMessage) -> Completable {
        implementMe
    }
}
