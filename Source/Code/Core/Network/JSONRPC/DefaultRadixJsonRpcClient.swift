//
//  DefaultRadixJsonRpcClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultRadixJsonRpcClient: RadixJsonRpcClient {
    
    /// The channel this JSON RPC client utilizes for messaging
    private let channel: PersistentChannel
    
    public init(persistentChannel: PersistentChannel) {
        self.channel = persistentChannel
    }
}

public extension DefaultRadixJsonRpcClient {
    
    func getInfo() -> Single<NodeRunnerData> {
        implementMe
    }
    
    func getLivePeers() -> Single<[NodeRunnerData]> {
        implementMe
    }
    
    func getAtom(by hashId: EUID) -> Maybe<Atom> {
        implementMe
    }
    
    func getAtoms(query: AtomQuery) -> Observable<AtomObservation> {
        implementMe
    }
    
    func submitAtom(_ atom: Atom) -> Observable<NodeAtomSubmissionUpdate> {
        implementMe
    }
}
