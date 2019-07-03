//
//  FullDuplexCommunicationChannel+RPC.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

extension FullDuplexCommunicationChannel {
    
    func responseForMessage<Model>(requestId: String) -> Observable<Model> where Model: Decodable {
        
        return responseOrErrorForMessage(requestId: requestId).map {
            try $0.get().model
        }
    }
    
    func responseOrErrorForMessage<Model>(requestId: String) -> Observable<RPCResult<Model>> where Model: Decodable {
        return resultForMessage(requestId: requestId)
    }
    
    func responseForMessage<Model>(notification: RPCNotification, subscriberId: SubscriberId) -> Observable<Model> where Model: Decodable {
        
        return resultForMessage(subscriberId: subscriberId, notification: notification).map {
            try $0.get().model
        }
    }
}

private extension FullDuplexCommunicationChannel {
    func resultForMessage<Model>(
        requestId: String? = nil,
        subscriberId: SubscriberId? = nil,
        notification: RPCNotification? = nil
    ) -> Observable<RPCResult<Model>> where Model: Decodable {
        
        return messagesDecoded()
            .filter(requestId: requestId, subscriberId: subscriberId, notification: notification)
    }
    
    func messagesDecoded<Model>() -> Observable<RPCResult<Model>> where Model: Decodable {
        return messages
            .map { $0.toData() }
            .map {
                try JSONDecoder().decode(RPCResult<Model>.self, from: $0)
            }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribeOn(MainScheduler.instance)
    }
}

//extension Swift.Result: BaseRPCResposeResult & PotentiallyRequestIdentifiable & PotentiallySubscriptionIdentifiable where Success: BaseRPCResposeResult & PotentiallyRequestIdentifiable & PotentiallySubscriptionIdentifiable {}

extension RPCResult: BaseRPCResposeResult where Success: BaseRPCResposeResult {
//    public var requestIdIfPresent: String? {
//        switch self {
//        case .success(let success):
//            
//            return success.requestIdIfPresent
//        case .failure: return nil
//        }
//    }
//    
//    public var subscriberIdIfPresent: SubscriberId? {
//        switch self {
//        case .success(let success): return success.subscriberIdIfPresent
//        case .failure: return nil
//        }
//    }
}

private extension ObservableType where Element: BaseRPCResposeResult {
    func filter(
        requestId: String? = nil,
        subscriberId: SubscriberId? = nil,
        notification: RPCNotification? = nil
    ) -> Observable<Element> {
        
        return self.asObservable().filter { element in
            if
                let requestId = requestId,
                let identifiableRequestResponse = element as? PotentiallyRequestIdentifiable,
                let elementRequestId = identifiableRequestResponse.requestIdIfPresent
            {
                guard elementRequestId == requestId else {
                    return false
                }
            }
            
            if
                let subscriberId = subscriberId,
                let subscribedRequestResponse = element as? PotentiallySubscriptionIdentifiable,
                let elementSubscriptionId = subscribedRequestResponse.subscriberIdIfPresent
            {
                guard elementSubscriptionId == subscriberId else {
                    return false
                }
            }
            
            if
                let notification = notification,
                let notificationResponse = element as? RPCNotificationResponseConvertible
            {
                guard notificationResponse.method == notification else {
                    return false
                }
            }
            
            return true
        }
    }
}

//extension ObservableType where Element: RPCSubscriptionResponseConvertible {
//    
//    
//    func filterOnSubscriberId(_ subscriberId: SubscriberId) -> Observable<Element> {
//        return asObservable()
//            .filter { $0.subscriberId == subscriberId }
//    }
//}
//
//extension ObservableType where Element: RPCSubscriptionResponseConvertible & RPCNotificationResponseConvertible {
//    
//    
//    func filterOnSubscriberId(_ subscriberId: SubscriberId, andNotification notificationMethod: RPCNotification) -> Observable<Element> {
//        return filterOnSubscriberId(subscriberId)
//            .filter { $0.method == notificationMethod }
//    }
//}
//
//
