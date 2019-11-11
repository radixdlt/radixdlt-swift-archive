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
import Combine

extension FullDuplexCommunicationChannel {
    
    func responseForMessage<Model>(requestId: String) -> AnyPublisher<Model, Never> where Model: Decodable {
        
//        return responseOrErrorForMessage(requestId: requestId).map {
//            try $0.get().model
//        }
        combineMigrationInProgress()
    }
    
    func responseOrErrorForMessage<Model>(requestId: String) -> AnyPublisher<RPCResult<Model>, Never> where Model: Decodable {
        return resultForMessage(parseMode: .responseOnRequest(withId: requestId))
    }
    
    func observeNotification<Model>(_ notification: RPCNotification, subscriberId: SubscriberId) -> AnyPublisher<Model, Never> where Model: Decodable {
        
        resultForMessage(
            parseMode: .parseAsNotification(notification, subscriberId: subscriberId)
        )
            // swiftlint:disable:next force_try
            .map { try! $0.get().model } // TODO Combine: change to `tryMap` and propagate error
            .eraseToAnyPublisher()
    }
}

private enum ParseJsonRpcResponseMode {
    case parseAsNotification(RPCNotification, subscriberId: SubscriberId)
    case responseOnRequest(withId: String)
}

private extension FullDuplexCommunicationChannel {

    func resultForMessage<Model>(
        parseMode: ParseJsonRpcResponseMode
    ) -> AnyPublisher<RPCResult<Model>, Never> where Model: Decodable {
       
        return messages
            .map { $0.toData() }
            .filter { self.filterOutRelevant(data: $0, parseMode: parseMode) }
            .decode(type: RPCResult<Model>.self, decoder: JSONDecoder())
            .mapError { fatalError("TODO Combine - handle error: \($0)") }
            .eraseToAnyPublisher()
            
//            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
//            .subscribeOn(MainScheduler.instance)
    }
    
    func filterOutRelevant(data: Data, parseMode: ParseJsonRpcResponseMode) -> Bool {
        guard
            let jsonObj = try? JSONSerialization.jsonObject(with: data, options: []) as? JSON
            else {
                incorrectImplementation("not json!")
        }
        
        switch parseMode {
        case .parseAsNotification(let expectedNotification, let expectedSubscriberId):
            guard
                let notificationMethodFromResponseAsString = jsonObj[RPCResponseLookingLikeRequestCodingKeys.method.rawValue] as? String,
                let notificationMethodFromResponse = RPCNotification(rawValue: notificationMethodFromResponseAsString),
                notificationMethodFromResponse == expectedNotification,
                let subscriberIdWrapperJson = jsonObj[RPCResponseLookingLikeRequestCodingKeys.params.rawValue] as? JSON,
                let subscriberIdFromResponseAsString = subscriberIdWrapperJson["subscriberId"] as? String,
                case let subscriberIdFromResponse = SubscriberId(validated: subscriberIdFromResponseAsString),
                subscriberIdFromResponse == expectedSubscriberId
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
}
