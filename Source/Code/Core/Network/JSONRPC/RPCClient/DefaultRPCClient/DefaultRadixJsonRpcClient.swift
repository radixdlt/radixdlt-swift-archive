//
//  DefaultRadixJsonRpcClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift
import JSONRPCKit

public final class DefaultRadixJsonRpcClient {
    
    /// The channel this JSON RPC client utilizes for messaging
    internal let channel: PersistentChannel
    
    internal let rpcRequestFactory = JSONRPCKit.BatchFactory()
    
    public init(persistentChannel: PersistentChannel) {
        self.channel = persistentChannel
    }
    
    deinit {
        log.warning("Deinit (might be relevant until life cycle is proper fixed)")
    }
}

// MARK: - RadixJsonRpcClient
public extension DefaultRadixJsonRpcClient {
    
    func getInfo() -> Single<NodeRunnerData> {
        implementMe
    }
    
    func getLivePeers() -> Observable<[NodeRunnerData]> {
        return makeRequest(JSONRPCMethodGetLivePeers())
    }
    
    func getUniverse() -> Observable<UniverseConfig> {
        return makeRequest(JSONRPCMethodGetUniverse())
    }
    
    func getAtom(by hashId: EUID) -> Maybe<Atom> {
        implementMe
    }
    
    func getAtoms(query: AtomQuery) -> Observable<AtomSubscription> {
        let rpcRequest = JSONRPCMethodAtomsSubscribe(query: query)
        return makeRequest(rpcRequest)
    }
    
    func submitAtom(_ atom: Atom) -> Observable<NodeAtomSubmissionUpdate> {
        implementMe
    }
}
