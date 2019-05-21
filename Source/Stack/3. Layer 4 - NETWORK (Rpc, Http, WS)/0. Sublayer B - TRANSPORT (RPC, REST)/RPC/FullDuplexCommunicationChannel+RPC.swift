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
        return resultForMessage(with: requestId).flatMapLatest { (result: RPCResult<Model>) -> Observable<Model> in
            switch result {
            case .success(let rpcResponse):
                log.verbose("RPC received model: \(rpcResponse.model)")
                return Observable.just(rpcResponse.model)
            case .failure(let error):
                log.error(error)
                return Observable.error(error)
            }
        }
    }
    
    func resultForMessage<Model>(with requestId: Int?) -> Observable<RPCResult<Model>> where Model: Decodable {
        
        let result: Observable<RPCResult<Model>> = messages
            .map { $0.toData() }
            .map {
                do {
                    let result = try JSONDecoder().decode(RPCResult<Model>.self, from: $0)
                    log.verbose("Parsed result from RPC:<\n\(result)\n>")
                    return result
                } catch {
                    log.error("Error: \(error)")
                    throw error
                }
                
            }  /// Perform callbacks (code within `subscribe(onNext:` blocks) on MainThread
            .observeOn(MainScheduler.instance)
            
            /// Perform work ("subscription code") on `background` thread.
            /// SeeAlso: http://rx-marin.com/post/observeon-vs-subscribeon/
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
        
        guard let requestId = requestId else {
            return result
        }
        return result.ifNeededFilterOnRequestId(requestId)
    }
}
