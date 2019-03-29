//
//  DefaultRadixJsonRpcClient+MakeRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-27.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift
import JSONRPCKit

internal extension DefaultRadixJsonRpcClient {
    
    func makeRequest<Request, Response>(_ request: Request) -> Observable<Response> where Request: JSONRPCKit.Request, Response == Request.Response {
        let batch = rpcRequestFactory.create(request)
        let requestId = batch.requestId
        let jsonString = batch.jsonString
        channel.sendMessage(jsonString)
        
        return channel.responseForMessage(with: requestId)
    }
}

extension PersistentChannel {
    func responseForMessage<Model>(with requestId: Int) -> Observable<Model> where Model: Decodable {
        return messages
            .map { $0.toData() }
            .map { try? JSONDecoder().decode(RPCResponse<Model>.self, from: $0) }
            .filterNil()
            .map { $0.ifNeededFilterOn(requestId: requestId) }
            .filterNil()
            .map { $0.model }
    }
}

private extension RPCResponse {
    func ifNeededFilterOn(requestId: Int) -> RPCResponse? {
        // If response contains id, filter on it
        if let resultWithRequestId = self.resultWithRequestId, resultWithRequestId.id != requestId {
            return nil
        }
        return self
    }
}
