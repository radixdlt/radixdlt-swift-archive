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
        
        return channel.responseForMessage(with: requestId).flatMapLatest { (result: RPCResult<Response>) -> Observable<Response> in
            switch result {
            case .success(let success): return Observable.just(success.model)
            case .failure(let error): return Observable.error(error)
            }
        }
    }
}

internal typealias RPCResult<Model: Decodable> = Swift.Result<RPCResponse<Model>, RPCError>

extension Result: Decodable where Success: Decodable, Failure == RPCError {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        do {
            self = .success(try container.decode(Success.self))
        } catch {
            self = .failure(try container.decode(RPCError.self))
        }
    }
}

extension PersistentChannel {
    func responseForMessage<Model>(with requestId: Int) -> Observable<RPCResult<Model>> where Model: Decodable {
        return messages
            .map { $0.toData() }
            .map { try? JSONDecoder().decode(RPCResult<Model>.self, from: $0) }
            .filterNil()
            .ifNeededFilterOnRequestId(requestId)
    }
}

extension ObservableType where E: PotentiallyRequestIdentifiable {
    func ifNeededFilterOnRequestId(_ requestId: Int) -> Observable<E> {
        // If response contains id, filter on it
        return self.asObservable().map { element -> E? in
            if let elementRequestId = element.requestIdIfPresent {
                guard elementRequestId == requestId else {
                    return nil
                }
            }
            return element
        }.filterNil()
    }
}

extension RPCResult: PotentiallyRequestIdentifiable where Success: RPCResposeResultConvertible {
    var requestIdIfPresent: Int? {
        switch self {
        case .success(let success): return success.requestIdIfPresent
        case .failure: return nil
        }
    }
}
