//
//  DefaultRPCClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift
import JSONRPCKit

public final class DefaultRPCClient: RPCClient {
    
    /// The channel this JSON RPC client utilizes for messaging
    public let channel: FullDuplexCommunicationChannel
    
    internal let rpcRequestFactory = JSONRPCKit.BatchFactory()
    
    public init(channel: FullDuplexCommunicationChannel) {
        self.channel = channel
    }
    
    deinit {
        log.error("💣")
    }
}

// MARK: - RPCClient
public extension DefaultRPCClient {
    
    func getInfo() -> SingleWanted<NodeInfo> {
        implementMe
    }
    
    func getLivePeers() -> SingleWanted<[NodeInfo]> {
        return makeRequest(JSONRPCMethodGetLivePeers())
    }
    
    func getUniverseConfig() -> SingleWanted<UniverseConfig> {
        return makeRequest(JSONRPCMethodGetUniverse())
    }
    
    func getAtoms(for address: Address) -> Observable<AtomSubscription> {
        let rpcRequest = JSONRPCMethodAtomsSubscribe(query: AtomQuery(address: address))
        return makeRequest(rpcRequest)
    }
    
    func submitAtom(_ atom: Atom) -> Observable<AtomSubscription> {
        let rpcRequest = JSONRPCMethodSubmitAtomAndSubscribe(atom: atom)
        return makeRequest(rpcRequest)
    }
}
