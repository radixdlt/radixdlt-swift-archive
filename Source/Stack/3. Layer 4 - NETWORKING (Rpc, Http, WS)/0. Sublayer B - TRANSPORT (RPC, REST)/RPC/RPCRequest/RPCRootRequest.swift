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
