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
        let atoms = nodeInteractor.subscribe(to: address)
            .map { (atomUpdates: [AtomUpdate]) -> [Atom] in
                return atomUpdates.compactMap {
                    guard $0.action == .store else { return nil }
                    return $0.atom
                }
        }
        return TokenBalanceReducer().reduce(atoms: atoms)
    }
    
    func makeTransaction(_ transaction: Transaction) -> Completable {
        implementMe
    }
    
    func sendChatMessage(_ message: ChatMessage) -> Completable {
        implementMe
    }
}
