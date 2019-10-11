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

public final class DefaultRPCClient: RPCClient, FullDuplexCommunicating {
    
    /// The channel this JSON RPC client uses for messaging
    public let channel: FullDuplexCommunicationChannel
    
    public init(channel: FullDuplexCommunicationChannel) {
        self.channel = channel
    }
}

// MARK: - Observing RPC Responses
public extension DefaultRPCClient {
    func observeAtoms(subscriberId: SubscriberId) -> CombineObservable<AtomObservation> {
//        return observe(notification: .subscribeUpdate, subscriberId: subscriberId, responseType: AtomSubscriptionUpdate.self)
//            .map { $0.toAtomObservation() }
//            .flatMap { (atomObservations: [AtomObservation]) -> CombineObservable<AtomObservation> in
//                return CombineObservable.from(atomObservations)
//            }
        combineMigrationInProgress()
    }
    
    func observeAtomStatusNotifications(subscriberId: SubscriberId) -> CombineObservable<AtomStatusEvent> {
        return self.observe(notification: .observeAtomStatusNotifications, subscriberId: subscriberId, responseType: AtomStatusEvent.self)
       
    }
}

// MARK: - Make RPC Requests

// MARK: - Single's
public extension DefaultRPCClient {
    func getNetworkInfo() -> CombineSingle<RadixSystem> {
        return make(request: .getNetworkInfo)
    }
    
    func getLivePeers() -> CombineSingle<[NodeInfo]> {
        return make(request: .getLivePeers)
    }
    
    func getUniverseConfig() -> CombineSingle<UniverseConfig> {
        return make(request: .getUniverse)
    }
    
    func statusOfAtom(withIdentifier atomIdentifier: AtomIdentifier) -> CombineSingle<AtomStatus> {
        return make(request: .getAtomStatus(atomIdentifier: atomIdentifier))
    }
}

// MARK: - CombineCompletable
public extension DefaultRPCClient {
    func pushAtom(_ atom: SignedAtom) -> CombineCompletable {
        return makeCompletableMapError(request: .submitAtom(atom: atom)) { SubmitAtomError(rpcError: $0) }
    }
}

// MARK: - Send Request for STARTING Subscribing To Some Notification
public extension DefaultRPCClient {
    
    func sendAtomsSubscribe(to address: Address, subscriberId: SubscriberId) -> CombineCompletable {
        return sendStartSubscription(request: .subscribe(to: address, subscriberId: subscriberId))
    }
    
    func sendGetAtomStatusNotifications(atomIdentifier: AtomIdentifier, subscriberId: SubscriberId) -> CombineCompletable {
        return sendStartSubscription(request: .getAtomStatusNotifications(atomIdentifier: atomIdentifier, subscriberId: subscriberId))
    }
}

// MARK: - Send Request for CLOSING Subscribing To Some Notification
public extension DefaultRPCClient {
    func closeAtomStatusNotifications(subscriberId: SubscriberId) -> CombineCompletable {
        return sendCancelSubscription(request: .closeAtomStatusNotifications(subscriberId: subscriberId))
    }
    
    func cancelAtomsSubscription(subscriberId: SubscriberId) -> CombineCompletable {
        return sendCancelSubscription(request: .unsubscribe(subscriberId: subscriberId))
    }
}

// MARK: Internal
internal extension DefaultRPCClient {
    
    func make<ResultFromResponse>(request rootRequest: RPCRootRequest) -> CombineSingle<ResultFromResponse> where ResultFromResponse: Decodable {
        return make(request: rootRequest, responseType: ResultFromResponse.self)
    }
    
    func makeCompletableMapError<ErrorToMapTo>(request rootRequest: RPCRootRequest, errorMapper: @escaping (RPCError) -> (ErrorToMapTo)) -> CombineCompletable where ErrorToMapTo: ErrorMappedFromRPCError {
        return make(request: rootRequest, responseType: ResponseOnFireAndForgetRequest.self, errorMapper: errorMapper).asCompletable()
    }
    
    func observe<NotificationResponse>(notification: RPCNotification, subscriberId: SubscriberId, responseType: NotificationResponse.Type) -> CombineObservable<NotificationResponse> where NotificationResponse: Decodable {
        return channel.observeNotification(notification, subscriberId: subscriberId)
    }
    
    func make<ResultFromResponse>(request rootRequest: RPCRootRequest, responseType: ResultFromResponse.Type) -> CombineSingle<ResultFromResponse> where ResultFromResponse: Decodable {
        let noMapper: ((RPCError) -> RPCError)? = nil
        return make(request: rootRequest, responseType: responseType, errorMapper: noMapper)
    }
    
    func make<ResultFromResponse, MapToError>(
        request rootRequest: RPCRootRequest,
        responseType: ResultFromResponse.Type,
        errorMapper: ((RPCError) -> MapToError)?
    ) -> CombineSingle<ResultFromResponse>
        where
        ResultFromResponse: Decodable,
        MapToError: ErrorMappedFromRPCError {
        
//        return makeRequestMapToResponseOrError(request: rootRequest, responseType: responseType).map {
//            do {
//                return try $0.get().model
//            } catch let rpcError as RPCError {
//                if let errorMapper = errorMapper {
//                    throw errorMapper(rpcError)
//                } else { throw rpcError }
//            } catch { unexpectedlyMissedToCatch(error: error) }
//        }
            combineMigrationInProgress()
    }
    
    func sendStartSubscription(request: RPCRootRequest) -> CombineCompletable {
        return sendStartOrCancelSubscription(request: request, mode: .start)
    }
    
    func sendCancelSubscription(request: RPCRootRequest) -> CombineCompletable {
        return sendStartOrCancelSubscription(request: request, mode: .cancel)
    }
}

// MARK: - Private
private extension DefaultRPCClient {
    
    func makeRequestMapToResponseOrError<Model>(request rootRequest: RPCRootRequest, responseType: Model.Type) -> CombineSingle<RPCResult<Model>> where Model: Decodable {
        
        let rpcRequest = RPCRequest(rootRequest: rootRequest)
        
        let message = rpcRequest.jsonString
        let requestId = rpcRequest.requestUuid
        
//        return channel.responseOrErrorForMessage(requestId: requestId).take(1).asSingle()
//            .do(onSubscribed: {
//                self.channel.sendMessage(message)
//            })
        
        combineMigrationInProgress()
    }
    
    func sendStartOrCancelSubscription(request: RPCRootRequest, mode: SubscriptionMode) -> CombineCompletable {
        combineMigrationInProgress()
//        return CombineCompletable.create { [unowned self] completable in
//            let singleCombineDisposable = self.make(request: request, responseType: RPCSubscriptionStartOrCancel.self)
//                .subscribe(
//                    onSuccess: { rpcResponseAboutSubscriptionChange in
//                        if rpcResponseAboutSubscriptionChange.success {
//                            completable(.completed)
//                        } else {
//                            completable(.error(RPCClientError(subscriptionMode: mode)))
//                        }
//                },
//                    onError: {
//                        // change to `completable(.error($0))`?
//                        unexpectedlyMissedToCatch(error: $0)
//                }
//            )
//            return CombineDisposables.create([singleCombineDisposable])
//        }
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
