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
    
    func responseForMessage<Model>(with requestId: Int?) -> Observable<Model> where Model: Decodable {
        
        return resultForMessage(with: requestId).map {
            try $0.get().model
        }
    }
    
    func resultForMessage<Model>(with requestId: Int?) -> Observable<RPCResult<Model>> where Model: Decodable {
        
        return messages
            .map { $0.toData() }
            .map {
               try JSONDecoder().decode(RPCResult<Model>.self, from: $0)
            }.ifNeededFilterOnRequestId(requestId)
            .observeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .subscribeOn(MainScheduler.instance)
    }
}
