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
import RxSwift

public final class DefaultRPCClient: RPCClient, FullDuplexCommunicating {
    
    /// The channel this JSON RPC client utilizes for messaging
    public let channel: FullDuplexCommunicationChannel
    
    public init(channel: FullDuplexCommunicationChannel) {
        self.channel = channel
    }
}

// MARK: - Observing RPC Responses
public extension DefaultRPCClient {
    func observeAtoms(subscriberId: SubscriberId) -> Observable<AtomObservation> {
        return observe(notification: .subscribeUpdate, subscriberId: subscriberId, responseType: AtomSubscriptionUpdate.self)
            .map { $0.toAtomObservation() }
            .flatMap { (atomObservations: [AtomObservation]) -> Observable<AtomObservation> in
                return Observable.from(atomObservations)
            }
    }
    
    func observeAtomStatusNotifications(subscriberId: SubscriberId) -> Observable<AtomStatusEvent> {
        return self.observe(notification: .observeAtomStatusNotifications, subscriberId: subscriberId, responseType: AtomStatusEvent.self)
       
    }
}

// MARK: - Make RPC Requests

// MARK: - Single's
public extension DefaultRPCClient {
    func getNetworkInfo() -> Single<RadixSystem> {
        return make(request: .getNetworkInfo)
    }
    
    func getLivePeers() -> Single<[NodeInfo]> {
        return make(request: .getLivePeers)
    }
    
    func getUniverseConfig() -> Single<UniverseConfig> {
        return make(request: .getUniverse)
    }
    
    func statusOfAtom(withIdentifier atomIdentifier: AtomIdentifier) -> Single<AtomStatus> {
        return make(request: .getAtomStatus(atomIdentifier: atomIdentifier))
    }
}

// MARK: - Completable
public extension DefaultRPCClient {
    func pushAtom(_ atom: SignedAtom) -> Completable {
        return makeCompletableMapError(request: .submitAtom(atom: atom)) { SubmitAtomError(rpcError: $0) }
    }
}

// MARK: - Send Request for STARTING Subscribing To Some Notification
public extension DefaultRPCClient {
    
    func sendAtomsSubscribe(to address: Address, subscriberId: SubscriberId) -> Completable {
        return sendStartSubscription(request: .subscribe(to: address, subscriberId: subscriberId))
    }
    
    func sendGetAtomStatusNotifications(atomIdentifier: AtomIdentifier, subscriberId: SubscriberId) -> Completable {
        return sendStartSubscription(request: .getAtomStatusNotifications(atomIdentifier: atomIdentifier, subscriberId: subscriberId))
    }
}

// MARK: - Send Request for CLOSING Subscribing To Some Notification
public extension DefaultRPCClient {
    func closeAtomStatusNotifications(subscriberId: SubscriberId) -> Completable {
        return sendCancelSubscription(request: .closeAtomStatusNotifications(subscriberId: subscriberId))
    }
    
    func cancelAtomsSubscription(subscriberId: SubscriberId) -> Completable {
        return sendCancelSubscription(request: .unsubscribe(subscriberId: subscriberId))
    }
}

// MARK: Internal
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
        MapToError: ErrorMappedFromRPCError {
        
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

// MARK: - Private
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

private extension RPCClientError {
    init(subscriptionMode: SubscriptionMode) {
        switch subscriptionMode {
        case .start: self = .failedToStartAtomSubscription
        case .cancel: self = .failedToCancelAtomSubscription
        }
    }
}

private enum SubscriptionMode: Int, Equatable {
    case start, cancel
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
