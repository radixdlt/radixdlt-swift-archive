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
                log.debug("STARTED DECODING RESULT (into \(type(of: Model.self))")
                do {
                    let result = try JSONDecoder().decode(RPCResult<Model>.self, from: $0)
                    log.debug("FINISHED PARSING RESULT from RPC:<\n\(result)\n>")
                    return result
                } catch {
                    log.error("FINISHED DECODING RESULT error: \(error)")
                    throw error
                }
                
            }.ifNeededFilterOnRequestId(requestId)
            
            /// Perform callbacks (code within `subscribe(onNext:` blocks) on MainThread
            .observeOn(MainScheduler.instance)
            
            /// Perform work ("subscription code") on `background` thread.
            /// SeeAlso: http://rx-marin.com/post/observeon-vs-subscribeon/
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
    }
}
