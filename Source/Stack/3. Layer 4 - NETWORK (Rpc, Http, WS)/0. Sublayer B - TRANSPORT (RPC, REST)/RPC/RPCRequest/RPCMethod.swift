//
//  RPCMethod.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// JSON-RPC methods according to [Radix JSON-RPC API docs][1]
///
/// This assumes that you're already are connected to a Node.
///
/// [1]: https://docs.radixdlt.com/node-api/-LWS9ny1CJ2AjPKy4lDP/json-rpc#api-methods
///
public enum RPCMethod {
    case subscribe(to: Address, subscriberId: SubscriberId)
    case unsubscribe(subscriberId: SubscriberId)
    case getLivePeers
    case getInfo
    case getUniverse
    case submitAndSubscribe(atom: SignedAtom, subscriberId: SubscriberId)
}

public enum RPCRequestMethod: String {
    case subscribe              = "Atoms.subscribe"
    case unsubscribe            = "Atoms.cancel"
    case getLivePeers           = "Network.getLivePeers"
    case getInfo                = "Network.getInfo"
    case getUniverse            = "Universe.getUniverse"
    case submitAndSubscribe     = "Universe.submitAtomAndSubscribe"
}

public enum RPCResponseMethod: String {
    case subscribeUpdate = "Atoms.subscribeUpdate"
    case submitAndSubscribe = "AtomSubmissionState.onNext"
}

public extension RPCMethod {
    
    typealias EncodeValue<K: CodingKey> = (inout KeyedEncodingContainer<K>) throws -> Void
    
    var method: RPCRequestMethod {
        switch self {
        case .subscribe: return .subscribe
        case .unsubscribe: return .unsubscribe
        case .getLivePeers: return .getLivePeers
        case .getInfo: return .getInfo
        case .getUniverse: return .getUniverse
        case .submitAndSubscribe: return .submitAndSubscribe
        }
    }
    
    func encodeParams<K>(key: K) -> EncodeValue<K> where K: CodingKey {
        
        func innerEncode<V>(_ value: V) -> EncodeValue<K> where V: Encodable {
            return { keyedEncodingContainer in
                try keyedEncodingContainer.encode(value, forKey: key)
            }
        }
        
        switch self {
        case .subscribe(let address, let subscriberId):
            let atomSubscriptionRequest = AtomSubscriptionRequest(address: address, subscriberId: subscriberId)
            return innerEncode(atomSubscriptionRequest)
        case .unsubscribe(let subscriberId):
            let unsubscriptionRequest = UnsubscriptionRequest(subscriberId: subscriberId)
            return innerEncode(unsubscriptionRequest)
        case .submitAndSubscribe(let atom, let subscriberId):
            let request = AtomSubmitAndSubscribeRequest(atom: atom, subscriberId: subscriberId)
            return innerEncode(request)
        case .getUniverse, .getInfo, .getLivePeers:
            return { keyedEncodingContainer in
                // We MUST encode some params, if nil, an empty array should be used, which element conforms to `Encodable`,
                // arbitrarily we chose [Int]
                try keyedEncodingContainer.encode([Int](), forKey: key)
            }
        }
    }
}

