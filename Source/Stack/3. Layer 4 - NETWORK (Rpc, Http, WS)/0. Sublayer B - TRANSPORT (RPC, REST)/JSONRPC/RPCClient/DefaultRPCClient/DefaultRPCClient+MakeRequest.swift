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

public protocol FullDuplexCommunicating {
    var channel: FullDuplexCommunicationChannel { get }
}

internal extension DefaultRPCClient {

    func makeRequest<Request, Response>(_ request: Request) -> Observable<Response> where Request: JSONRPCKit.Request, Response == Request.Response {
        let batch = rpcRequestFactory.create(request)
        return makeRequest(jsonMessage: batch.jsonString, requestId: batch.requestId)
    }
}

public extension RPCClient where Self: FullDuplexCommunicating {
    func makeRequest<Response>(jsonMessage: String, requestId: Int) -> Observable<Response> where Response: Decodable {
        channel.sendMessage(jsonMessage)
        return channel.responseForMessage(with: requestId)
    }
}

extension FullDuplexCommunicationChannel {

    func responseForMessage<Model>(with requestId: Int) -> Observable<Model> where Model: Decodable {
        return resultForMessage(with: requestId).flatMapLatest { (result: RPCResult<Model>) -> Observable<Model> in
            switch result {
            case .success(let rpcResponse): return Observable.just(rpcResponse.model)
            case .failure(let error):
                log.error("RPC error: \(error)")
                return Observable.error(error)
            }
        }
    }

    func resultForMessage<Model>(with requestId: Int) -> Observable<RPCResult<Model>> where Model: Decodable {
        return messages
            .map { $0.toData() }
            .map {
                // This assert is commented out since our unit tests are using `toBlocking()` which switches to MainThread
                //                        assert(!Thread.isMainThread, "Should not perform network requests on MainThread, check `subscribeOn`")
                do {
                    let result = try JSONDecoder().decode(RPCResult<Model>.self, from: $0)
                    log.verbose("Parsed result from RPC:<\n\(result)\n>")
                    return result
                } catch {
                    incorrectImplementation("Error: \(error)")
                }
                
            }  /// Perform callbacks (code within `subscribe(onNext:` blocks) on MainThread
            .observeOn(MainScheduler.instance)
            
            /// Perform work ("subscription code") on `background` thread.
            /// SeeAlso: http://rx-marin.com/post/observeon-vs-subscribeon/
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .ifNeededFilterOnRequestId(requestId)
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
