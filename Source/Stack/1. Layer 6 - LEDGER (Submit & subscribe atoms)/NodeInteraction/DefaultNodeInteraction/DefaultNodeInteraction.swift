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
    private let rpcClient: Observable<RPCClient>

    public init(_ nodeDiscovery: NodeDiscovery) {
        self.futureNodeConnection = DefaultNodeConnection.byNodeDiscovery(nodeDiscovery).map { $0 }
        self.rpcClient = futureNodeConnection.map { $0.rpcClient }
    }
}

// MARK: - NodeInteractionSubscribing
public extension DefaultNodeInteraction {
    
    func subscribe(to address: Address) -> Observable<[AtomUpdate]> {
        let id = SubscriptionIdIncrementingGenerator.next()
        return rpcClient.flatMapLatest { $0.subscribe(to: address, subscriberId: id) }
            .assertSubscriptionStarted()
            .mapToUpdateTypeElseReturnEmpty(type: AtomSubscriptionUpdateSubscribe.self)
            .map { $0.toAtomUpdates() }
    }
}

// MARK: - NodeInteractionSubmitting
public extension DefaultNodeInteraction {
    
    func submit(atom: SignedAtom) -> CompletableWanted {
        let id = SubscriptionIdIncrementingGenerator.next()
        return rpcClient.flatMap { $0.submit(atom: atom, subscriberId: id) }
            .assertSubscriptionStarted()
            .mapToUpdateTypeElseReturnEmpty(type: AtomSubscriptionUpdateSubmitAndSubscribe.self)
            .assertAtomGotStored()
        
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
    func assertSubscriptionStarted() -> Observable<E> {
        return asObservable().flatMap { (atomSubscription: AtomSubscription) -> Observable<AtomSubscription> in
            if let start = atomSubscription.start, start.success == false {
                return Observable.error(DefaultNodeInteraction.Error.failedToStartSubscribeToNode)
            } else {
                return Observable.just(atomSubscription)
            }
        }
    }

    func mapToUpdateTypeElseReturnEmpty<U: SubscriptionUpdateValue>(type: U.Type) -> Observable<U> {
        return self.asObservable()
            .map { $0.update }
            .filterNil()
            .map { $0.mapTo(type: U.self) }
            .filterNil()
    }
}

extension ObservableType where E == AtomSubscriptionUpdateSubmitAndSubscribe {
    /// Assert that the submitted Atom got stored, else throw error
    func assertAtomGotStored() -> Observable<Void> {
        return self.asObservable()
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
