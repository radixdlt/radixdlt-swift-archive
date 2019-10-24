//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
    case submitAtom(atom: SignedAtom)

    case getAtomStatus(atomIdentifier: AtomIdentifier)
    case getAtomStatusNotifications(atomIdentifier: AtomIdentifier, subscriberId: SubscriberId)
    case closeAtomStatusNotifications(subscriberId: SubscriberId)

    case getAtom(byHashId: HashEUID)

    case getLivePeers
    case getNetworkInfo
    case getUniverse
//    case submitAndSubscribe(atom: SignedAtom, subscriberId: SubscriberId)
}

public enum RPCRootRequest {
    case fireAndForget(RPCMethod)
    case sendAndListenToNotifications(RPCMethod, RPCNotification)
}

public extension RPCRootRequest {
    
    static func subscribe(to address: Address, subscriberId: SubscriberId) -> RPCRootRequest {
        return .sendAndListenToNotifications(
            .subscribe(to: address, subscriberId: subscriberId),
            .subscribeUpdate
        )
    }
    
    static func unsubscribe(subscriberId: SubscriberId) -> RPCRootRequest {
        return .fireAndForget(.unsubscribe(subscriberId: subscriberId))
    }
    
    static func submitAtom(atom: SignedAtom) -> RPCRootRequest {
        return .fireAndForget(.submitAtom(atom: atom))
    }

    static func getAtomStatus(atomIdentifier: AtomIdentifier) -> RPCRootRequest {
        return .fireAndForget(.getAtomStatus(atomIdentifier: atomIdentifier))
    }
    
    static func getAtomStatusNotifications(atomIdentifier: AtomIdentifier, subscriberId: SubscriberId) -> RPCRootRequest {
        return .fireAndForget(.getAtomStatusNotifications(atomIdentifier: atomIdentifier, subscriberId: subscriberId))
    }
    
    static func closeAtomStatusNotifications(subscriberId: SubscriberId) -> RPCRootRequest {
        return .fireAndForget(.closeAtomStatusNotifications(subscriberId: subscriberId))
    }

    static func getAtom(byHashId hashEUID: HashEUID) -> RPCRootRequest {
        return .fireAndForget(.getAtom(byHashId: hashEUID))
    }

    static var getLivePeers: RPCRootRequest {
        return .fireAndForget(.getLivePeers)
    }
    
    static var getNetworkInfo: RPCRootRequest {
        return .fireAndForget(.getNetworkInfo)
    }
    
    static var getUniverse: RPCRootRequest {
        return .fireAndForget(.getUniverse)
    }
}

public enum RPCRequestMethod: String {
    case subscribe                      = "Atoms.subscribe"
    case unsubscribe                    = "Atoms.cancel"
    case submitAtom                     = "Atoms.submitAtom"
    
    case getAtomStatus                  = "Atoms.getAtomStatus"
    case getAtomStatusNotifications     = "Atoms.getAtomStatusNotifications"
    case closeAtomStatusNotifications   = "Atoms.closeAtomStatusNotifications"

    case getAtom                        = "Ledger.getAtoms"
    
    case getLivePeers                   = "Network.getLivePeers"
    case getNetworkInfo                 = "Network.getInfo"
    case getUniverse                    = "Universe.getUniverse"
//    case submitAndSubscribe             = "Universe.submitAtomAndSubscribe"
}

public enum RPCNotification: String, Equatable, Decodable {
    case observeAtomStatusNotifications = "Atoms.nextStatusEvent"
    case subscribeUpdate                = "Atoms.subscribeUpdate"
}

//public enum RPCResponseMethod: String {
//    case subscribeUpdate = "Atoms.subscribeUpdate"
//    case submitAndSubscribe = "AtomSubmissionState.onNext"
//}

public extension RPCMethod {
    
    typealias EncodeValue<K: CodingKey> = (inout KeyedEncodingContainer<K>) throws -> Void
    
    var method: RPCRequestMethod {
        switch self {
        case .subscribe: return .subscribe
        case .unsubscribe: return .unsubscribe
        case .submitAtom: return .submitAtom

        case .getAtomStatus: return .getAtomStatus
        case .getAtomStatusNotifications: return .getAtomStatusNotifications
        case .closeAtomStatusNotifications: return .closeAtomStatusNotifications

        case .getAtom: return .getAtom

        case .getLivePeers: return .getLivePeers
        case .getNetworkInfo: return .getNetworkInfo
        case .getUniverse: return .getUniverse
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
        case .submitAtom(let atom):
            let atomToEncode = atom.atomWithFee.wrappedAtom
            return innerEncode(atomToEncode)
        case .getAtomStatus(let atomIdentifier):
            let request = GetAtomStatusRequest(atomIdentifier: atomIdentifier)
            return innerEncode(request)
        case .getAtom(let atomHashIdentifier):
            let request = GetAtomRequest(atomHashIdentifier: atomHashIdentifier)
            return innerEncode(request)
        case .getAtomStatusNotifications(let atomIdentifier, let subscriberId):
            let request = GetAtomStatusNotificationRequest(atomIdentifier: atomIdentifier, subscriberId: subscriberId)
            return innerEncode(request)
        case .closeAtomStatusNotifications(let subscriberId):
            let request = CloseAtomStatusNotificationRequest(subscriberId: subscriberId)
            return innerEncode(request)
        case .getUniverse, .getNetworkInfo, .getLivePeers:
            return { keyedEncodingContainer in
                // We MUST encode some params, if nil, an empty array should be used, which element conforms to `Encodable`,
                // arbitrarily we chose [Int]
                try keyedEncodingContainer.encode([Int](), forKey: key)
            }
        }
    }
}

