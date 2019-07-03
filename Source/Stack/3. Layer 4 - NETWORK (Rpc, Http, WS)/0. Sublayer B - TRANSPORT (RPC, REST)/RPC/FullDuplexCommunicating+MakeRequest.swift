//
//  RPCClient+MakeRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

/// Used in RPC for Completable requests, where we just care if the request did not result in error, but we dont care about anything else.
internal struct NoneErrorResponse: Decodable {
    
    public init (from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let anyDecodable = try singleValueContainer.decode(AnyDecodable.self)
        let jsonString = String(describing: anyDecodable.value)
        guard !jsonString.contains("error") else {
            throw RPCError.unrecognizedJson(jsonString: jsonString)
        }
        // all good
    }
}

internal protocol ErrorMappedFromRPCError: Swift.Error {
    init(rpcError: RPCError)
}
// So that we can pass no error mapper, by passing Generic Optional problem, by using ` let noMapper: ((RPCError) -> RPCError)? = nil`
extension RPCError: ErrorMappedFromRPCError {
    init(rpcError: RPCError) {
        self = rpcError
    }
}

// MARK: - MakeRequest
internal extension FullDuplexCommunicating {

    func make<ResultFromResponse>(request rootRequest: RPCRootRequest) -> Observable<ResultFromResponse> where ResultFromResponse: Decodable {
        return make(request: rootRequest, resoponseType: ResultFromResponse.self)
    }
    
    func makeCompletable(request rootRequest: RPCRootRequest) -> Completable {
        return make(request: rootRequest, resoponseType: NoneErrorResponse.self).ignoreElements()
    }
    
    func makeCompletableMapError<ErrorToMapTo>(request rootRequest: RPCRootRequest, errorMapper: @escaping (RPCError) -> (ErrorToMapTo)) -> Completable where ErrorToMapTo: ErrorMappedFromRPCError {
        return make(request: rootRequest, resoponseType: NoneErrorResponse.self, errorMapper: errorMapper).ignoreElements()
    }
    
    func startSubscription(request rootRequest: RPCRootRequest) -> Completable {
        return make(request: rootRequest, resoponseType: NoneErrorResponse.self).ignoreElements()
    }

    func observe<NotificationResponse>(notification: RPCNotification, subscriberId: SubscriberId, responseType: NotificationResponse.Type) -> Observable<NotificationResponse> where NotificationResponse: Decodable {
        return channel.responseForMessage(notification: notification, subscriberId: subscriberId)
    }
    
    func make<ResultFromResponse>(request rootRequest: RPCRootRequest, resoponseType: ResultFromResponse.Type) -> Observable<ResultFromResponse> where ResultFromResponse: Decodable {
        let noMapper: ((RPCError) -> RPCError)? = nil
        return make(request: rootRequest, resoponseType: resoponseType, errorMapper: noMapper)
    }

    func make<ResultFromResponse, MapToError>(request rootRequest: RPCRootRequest, resoponseType: ResultFromResponse.Type, errorMapper: ((RPCError) -> MapToError)?) -> Observable<ResultFromResponse> where ResultFromResponse: Decodable, MapToError: ErrorMappedFromRPCError {
        return makeRequestMapToResponseOrError(request: rootRequest, resoponseType: resoponseType).map {
            do {
                return try $0.get().model
            } catch let rpcError as RPCError {
                if let errorMapper = errorMapper {
                    throw errorMapper(rpcError)
                } else { throw rpcError }
            } catch { unexpectedlyMissedToCatch(error: error) }
        }
    }
}

private extension FullDuplexCommunicating {
    
    func makeRequestMapToResponseOrError<Model>(request rootRequest: RPCRootRequest, resoponseType: Model.Type) -> Observable<RPCResult<Model>> where Model: Decodable {
        
        let rpcRequest = RPCRequest(rootRequest: rootRequest)
        
        let message = rpcRequest.jsonString
        let requestId = rpcRequest.requestUuid
        
        return channel.responseOrErrorForMessage(requestId: requestId)
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
