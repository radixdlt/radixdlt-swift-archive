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
        return resultForMessage(parseMode: .responseOnRequest(withId: requestId))
    }
    
    func observeNotification<Model>(_ notification: RPCNotification, subscriberId: SubscriberId) -> Observable<Model> where Model: Decodable {
        
        return resultForMessage(parseMode: .parseAsNotification(notification, subscriberId: subscriberId)).map {
            try $0.get().model
        }
    }
}

private enum ParseJsonRpcResponseMode {
    case parseAsNotification(RPCNotification, subscriberId: SubscriberId)
    case responseOnRequest(withId: String)
}

public enum RPCNotificationError: Swift.Error, Equatable {
    case failedToStartObservingNotification(RPCNotification, subscriberId: SubscriberId)
}

private extension FullDuplexCommunicationChannel {

    // swiftlint:disable:next function_body_length
    func resultForMessage<Model>(
        parseMode: ParseJsonRpcResponseMode
    ) -> Observable<RPCResult<Model>> where Model: Decodable {

        return messages
            .map { $0.toData() }
            .filter {
                guard
                    let jsonObj = try? JSONSerialization.jsonObject(with: $0, options: []) as? JSON
                    else {
                       incorrectImplementation("not json!")
                }
                
                switch parseMode {
                case .parseAsNotification(let expectedNotification, let expectedSubscriberId):
                    guard
                        let notificationMethodFromResponseAsString = jsonObj[RPCResponseLookingLikeRequestCodingKeys.method.rawValue] as? String,
                        let notificationMethodFromRespons = RPCNotification(rawValue: notificationMethodFromResponseAsString),
                        notificationMethodFromRespons == expectedNotification,
                        let subscriberIdWrapperJson = jsonObj[RPCResponseLookingLikeRequestCodingKeys.params.rawValue] as? JSON,
                        let subscriberIdFromResponseAsString = subscriberIdWrapperJson["subscriberId"] as? String,
                        case let subscriberIdFromRespons = SubscriberId(validated: subscriberIdFromResponseAsString),
                        subscriberIdFromRespons == expectedSubscriberId
                    else {
                        return false
                    }
                    return true
                    
                case .responseOnRequest(let rpcRequestId):
                    guard
                        let requestIdFromResponse = jsonObj[RPCResponseResultWithRequestIdCodingKeys.id.rawValue] as? String,
                        requestIdFromResponse == rpcRequestId
                        else {
                            return false
                            
                    }
                    return true
                }
            }
            .map { try JSONDecoder().decode(RPCResult<Model>.self, from: $0) }
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribeOn(MainScheduler.instance)
    }
}
