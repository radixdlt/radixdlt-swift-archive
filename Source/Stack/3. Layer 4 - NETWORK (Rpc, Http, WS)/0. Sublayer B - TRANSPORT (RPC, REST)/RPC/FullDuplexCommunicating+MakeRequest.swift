//
//  RPCClient+MakeRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public enum RPCClientError: Swift.Error, Equatable {
    case failedToCancelAtomSubscription
    case failedToStartAtomSubscription
}
private extension RPCClientError {
    init(subscriptionMode: SubscriptionMode) {
        switch subscriptionMode {
        case .start: self = .failedToStartAtomSubscription
        case .cancel: self = .failedToCancelAtomSubscription
        }
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

/// Used in RPC for Completable requests, where we just care if the request did not result in error, but we dont care about anything else.
internal struct ResponseOnFireAndForgetRequest: Decodable {
    
    public init (from decoder: Decoder) throws {
        let singleValueContainer = try decoder.singleValueContainer()
        let anyDecodable = try singleValueContainer.decode(AnyDecodable.self)
        guard let json = anyDecodable.value as? JSON else {
            incorrectImplementation("should be JSON")
        }
        if let anySuccessValue = json["success"] {
            guard let successValue = anySuccessValue as? Bool, case let wasSuccessful = successValue else {
                incorrectImplementation("should be bool")
            }
            if wasSuccessful {
                // ALL OK!
            } else {
                incorrectImplementation("expected error...")
            }
        } else if let anyErrorValue = json["error"] {
            throw RPCError.unrecognizedJson(jsonString: String(describing: anyErrorValue))
        }
        
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
internal extension DefaultRPCClient {

    func make<ResultFromResponse>(request rootRequest: RPCRootRequest) -> Single<ResultFromResponse> where ResultFromResponse: Decodable {
        return make(request: rootRequest, responseType: ResultFromResponse.self)
    }
    
    func makeCompletableMapError<ErrorToMapTo>(request rootRequest: RPCRootRequest, errorMapper: @escaping (RPCError) -> (ErrorToMapTo)) -> Completable where ErrorToMapTo: ErrorMappedFromRPCError {
        return make(request: rootRequest, responseType: ResponseOnFireAndForgetRequest.self, errorMapper: errorMapper).asCompletable()
    }

    func observe<NotificationResponse>(notification: RPCNotification, subscriberId: SubscriberId, responseType: NotificationResponse.Type) -> Observable<NotificationResponse> where NotificationResponse: Decodable {
        return channel.observeNotification(notification, subscriberId: subscriberId)
    }
    
    func make<ResultFromResponse>(request rootRequest: RPCRootRequest, responseType: ResultFromResponse.Type) -> Single<ResultFromResponse> where ResultFromResponse: Decodable {
        let noMapper: ((RPCError) -> RPCError)? = nil
        return make(request: rootRequest, responseType: responseType, errorMapper: noMapper)
    }

    func make<ResultFromResponse, MapToError>(
        request rootRequest: RPCRootRequest,
        responseType: ResultFromResponse.Type,
        errorMapper: ((RPCError) -> MapToError)?
    ) -> Single<ResultFromResponse>
        where
        ResultFromResponse: Decodable,
        MapToError: ErrorMappedFromRPCError
        // swiftlint:disable:next opening_brace
    {
        
        return makeRequestMapToResponseOrError(request: rootRequest, responseType: responseType).map {
            do {
                return try $0.get().model
            } catch let rpcError as RPCError {
                if let errorMapper = errorMapper {
                    throw errorMapper(rpcError)
                } else { throw rpcError }
            } catch { unexpectedlyMissedToCatch(error: error) }
        }
    }
    
    func sendStartSubscription(request: RPCRootRequest) -> Completable {
        return sendStartOrCancelSubscription(request: request, mode: .start)
    }
    
    func sendCancelSubscription(request: RPCRootRequest) -> Completable {
        return sendStartOrCancelSubscription(request: request, mode: .cancel)
    }
}

private extension DefaultRPCClient {
    
    func makeRequestMapToResponseOrError<Model>(request rootRequest: RPCRootRequest, responseType: Model.Type) -> Single<RPCResult<Model>> where Model: Decodable {
        
        let rpcRequest = RPCRequest(rootRequest: rootRequest)
        
        let message = rpcRequest.jsonString
        let requestId = rpcRequest.requestUuid
        
        return channel.responseOrErrorForMessage(requestId: requestId).take(1).asSingle()
            .do(onSubscribed: {
                self.channel.sendMessage(message)
            })
    }
    

    func sendStartOrCancelSubscription(request: RPCRootRequest, mode: SubscriptionMode) -> Completable {
        return Completable.create { [unowned self] completable in
            let singleDisposable = self.make(request: request, responseType: RPCSubscriptionStartOrCancel.self)
                .subscribe(
                    onSuccess: { rpcResponseAboutSubscriptionChange in
                        if rpcResponseAboutSubscriptionChange.success {
                            completable(.completed)
                        } else {
                            completable(.error(RPCClientError(subscriptionMode: mode)))
                        }
                    },
                    onError: {
                        // change to `completable(.error($0))`?
                        unexpectedlyMissedToCatch(error: $0)
                    }
                )
            return Disposables.create([singleDisposable])
        }
    }
}

private enum SubscriptionMode: Int, Equatable {
    case start, cancel
}
