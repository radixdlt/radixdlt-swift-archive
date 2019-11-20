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
    public unowned let channel: FullDuplexCommunicationChannel
    
    public init(channel: FullDuplexCommunicationChannel) {
        self.channel = channel
    }
}

// MARK: - Observing RPC Responses
public extension DefaultRPCClient {
    func observeAtoms(subscriberId: SubscriberId) -> AnyPublisher<AtomObservation, Never> {
        observe(
            notification: .subscribeUpdate,
            subscriberId: subscriberId,
            responseType: AtomSubscriptionUpdate.self
        )
            .map { $0.toAtomObservation() }
            .flattenSequence()
    }
    
    func observeAtomStatusNotifications(subscriberId: SubscriberId) -> AnyPublisher<AtomStatusEvent, Never> {
        observe(
            notification: .observeAtomStatusNotifications,
            subscriberId: subscriberId,
            responseType: AtomStatusEvent.self
        )
        
    }
}

// MARK: - Make RPC Requests

// MARK: - Single's
public extension DefaultRPCClient {
    
    func getNetworkInfo() -> Single<RadixSystem, Never> {
        return make(request: .getNetworkInfo)
            .crashOnFailure()
    }
    
    func getLivePeers() -> Single<[NodeInfo], Never> {
        return make(request: .getLivePeers)
        .crashOnFailure()
    }
    
    func getUniverseConfig() -> Single<UniverseConfig, Never> {
        return make(request: .getUniverse)
        .crashOnFailure()
    }
    
    func statusOfAtom(withIdentifier atomIdentifier: AtomIdentifier) -> Single<AtomStatus, Never> {
        return make(request: .getAtomStatus(atomIdentifier: atomIdentifier))
        .crashOnFailure()
    }
}

// MARK: - Completable
public extension DefaultRPCClient {
    func pushAtom(_ atom: SignedAtom) -> AnyPublisher<Never, SubmitAtomError> {
        makeFireForget(request: .submitAtom(atom: atom))
            .mapError { SubmitAtomError(rpcError: $0) }
            .eraseToAnyPublisher()
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
    
    func make<ResultFromResponse>(request rootRequest: RPCRootRequest) -> Single<ResultFromResponse, RPCError> where ResultFromResponse: Decodable {
        make(request: rootRequest, responseType: ResultFromResponse.self)
    }
    
    func makeFireForget(request rootRequest: RPCRootRequest) -> Single<Never, RPCError> {
        return make(
            request: rootRequest,
            responseType: ResponseOnFireAndForgetRequest.self
        ).ignoreOutput().eraseToAnyPublisher()
    }
    
    func make<ResultFromResponse>(
        request rootRequest: RPCRootRequest,
        responseType: ResultFromResponse.Type
    ) -> Single<ResultFromResponse, RPCError>
        where
        ResultFromResponse: Decodable {

        let rpcRequest = RPCRequest(rootRequest: rootRequest)
        
        let message = rpcRequest.jsonString
        let requestId = rpcRequest.requestUuid
        
        return channel.responseOrErrorForMessage(requestId: requestId)
            .first()
            .handleEvents(
                receiveSubscription: { _ in
                    self.channel.sendMessage(message)
            }
        )
            .eraseToAnyPublisher()
    }
    
    func observe<NotificationResponse>(
        notification: RPCNotification,
        subscriberId: SubscriberId,
        responseType: NotificationResponse.Type
    ) -> AnyPublisher<NotificationResponse, Never> where NotificationResponse: Decodable {
        
        channel.observeNotification(notification, subscriberId: subscriberId)
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
    
    func sendStartOrCancelSubscription(request: RPCRootRequest, mode: SubscriptionMode) -> Completable {
        
        self.make(request: request, responseType: RPCSubscriptionStartOrCancel.self)
            .filter { rpcSubscriptionStartOrCancel in
                guard rpcSubscriptionStartOrCancel.success else {
                    fatalError("TODO Combine handle failed to subscribe, throw `RPCClientError:subscriptionMode`, and deal with error flow")
                }
                return true
        }
        .crashOnFailure()
        .first()
        .ignoreOutput()
        .eraseToAnyPublisher()
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
            incorrectImplementation("Should be able to encode 'self' to JSON string")
        }
    }
}
