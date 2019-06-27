//
//  RPCClient+MakeRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

/// Ugly hack to simulate `Void`, but that is marked to be conforming to `Decodable`
internal struct VoidResponse: Decodable {}

// MARK: - MakeRequest
internal extension FullDuplexCommunicating {

    func make<ResultFromResponse>(request rootRequest: RPCRootRequest) -> Observable<ResultFromResponse> where ResultFromResponse: Decodable {
        return make(request: rootRequest, resoponseType: ResultFromResponse.self)
    }
    
    func makeVoid(request rootRequest: RPCRootRequest) -> CompletableWanted {
        return make(request: rootRequest, resoponseType: VoidResponse.self).mapToVoid()
    }

    func observe<NotificationResponse>(notification: RPCNotification, subscriberId: SubscriberId) -> Observable<NotificationResponse> where NotificationResponse: Decodable {
        return channel.responseForMessage(notification: notification, subscriberId: subscriberId)
    }
}

private extension FullDuplexCommunicating {
    func make<ResultFromResponse>(request rootRequest: RPCRootRequest, resoponseType: ResultFromResponse.Type) -> Observable<ResultFromResponse> where ResultFromResponse: Decodable {
        
        //        let rpcRequest = RPCRequest(method: method)
        let rpcRequest = RPCRequest(rootRequest: rootRequest)
        
        let message = rpcRequest.jsonString
        let requestId = rpcRequest.requestId
        
        return channel.responseForMessage(requestId: requestId)
            .do(onSubscribed: {
                self.channel.sendMessage(message)
            })
    }
}

private extension RPCRequest {
    var jsonString: String {
        do {
            let data = try RadixJSONEncoder().encode(self)
            return String(data: data)
        } catch {
            incorrectImplementation("Should be able to encode `self` to JSON string")
        }
    }
}
