//
//  DefaultNodeInteraction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultNodeInteraction: NodeInteraction {

    private let futureNodeConnection: Observable<NodeConnection>
    private var publicKeyHashIdToSubscriberId: PublicKeyHashIdToSubscriberId = [:]
    private var subscriptions: Subscriptions = [:]
    private var pendingSubmissions: PendingSubmissions = [:]

    public init(_ nodeDiscovery: NodeDiscovery) {
        self.futureNodeConnection = DefaultNodeConnection.byNodeDiscovery(nodeDiscovery).map { $0 }
    }
}

// MARK: - NodeInteractionSubscribing
public extension DefaultNodeInteraction {
    
    func subscribe(to address: Address) -> Observable<[AtomUpdate]> {
        
        let subscriberId = reuseSubscriberIdElseCreateNew(for: address.publicKey.hashId)
        
        let subscription: Observable<AtomSubscriptionUpdateSubscribe> = subscriptions.valueForKey(key: subscriberId) { [weak self] in
            guard let self = self else { return Observable.error(Error.deallocated) }
            return self.futureNodeConnection
                .flatMap { $0.rpcClient
                    .subscribe(to: address, subscriberId: subscriberId)
                    .ensureSucessfullSubscriptionStart()
                    .mapToUpdateElseReturnEmpty()
                    .mapToUpdateTypeElseReturnEmpty(type: AtomSubscriptionUpdateSubscribe.self)
            }
        }
        
        return subscription
            .map { $0.toAtomUpdates() }
    }
}

// MARK: - NodeInteractionSubmitting
public extension DefaultNodeInteraction {
    
    func submit(atom: SignedAtom) -> CompletableWanted {
        let atomId = atom.hashId
   
        let pendingSubmission = pendingSubmissions.valueForKey(key: atomId) { [weak self] in
            
            guard let self = self else {
                return Observable.error(DefaultNodeInteraction.Error.deallocated)
            }
            
            // Actually easist to just use a new subscription
            let subscriptionId = SubscriptionIdIncrementingGenerator.next()
            
            return self.futureNodeConnection.flatMap { $0.rpcClient
                .submit(atom: atom, subscriberId: subscriptionId)
                .ensureSucessfullSubscriptionStart()
                .mapToUpdateElseReturnEmpty()
                .mapToUpdateTypeElseReturnEmpty(type: AtomSubscriptionUpdateSubmitAndSubscribe.self)
            }
        }
        
        return pendingSubmission
            .map { $0.value }
            .map { state -> Void in
                guard case .stored = state else {
                    if case .received = state {
                        log.warning("Atom was 'received', instead of 'stored', should we really throw an error?")
                    }
                    throw DefaultNodeInteraction.Error.atomNotStored(state: state)
                }
                return ()
        }
    }
}

// MARK: - NodeInteractionUnsubscribing
public extension DefaultNodeInteraction {
    
    func unsubscribe(from address: Address) -> CompletableWanted {
        implementMe
    }
    
    func unsubscribeAll() -> CompletableWanted {
        implementMe
    }
}

// MARK: - Subscriptions
private extension DefaultNodeInteraction {
    
    func reuseSubscriberIdElseCreateNew(for key: PublicKeyHashIdToSubscriberId.Key) -> SubscriberId {
        return publicKeyHashIdToSubscriberId.valueForKey(key: key) {
            SubscriptionIdIncrementingGenerator.next()
        }
    }
}

// MARK: - Error
public extension DefaultNodeInteraction {
    enum Error: Swift.Error {
        case deallocated
        case failedToStartSubscribeToNode
        case atomNotStored(state: AtomSubscriptionUpdateSubmitAndSubscribe.State)
    }
}

// MARK: - Observable + AtomSubscription
extension ObservableType where E == AtomSubscription {
    func ensureSucessfullSubscriptionStart() -> Observable<E> {
        return asObservable().flatMap { (atomSubscription: AtomSubscription) -> Observable<AtomSubscription> in
            if let start = atomSubscription.start, start.success == false {
                return Observable.error(DefaultNodeInteraction.Error.failedToStartSubscribeToNode)
            } else {
                return Observable.just(atomSubscription)
            }
        }
    }

    func mapToUpdateElseReturnEmpty() -> Observable<AtomSubscriptionUpdate> {
        return self.asObservable()
            .map { $0.update }
            .filterNil()
    }
}

extension ObservableType where E == AtomSubscriptionUpdate {
    func mapToUpdateTypeElseReturnEmpty<U: SubscriptionUpdateValue>(type: U.Type) -> Observable<U> {
        return self.asObservable()
            .map { $0.mapTo(type: U.self) }
            .filterNil()
    }
}
