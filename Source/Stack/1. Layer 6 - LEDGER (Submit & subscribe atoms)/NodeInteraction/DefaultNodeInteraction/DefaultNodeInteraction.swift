//
//  DefaultNodeInteraction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public struct AddressToSubscriberId: DictionaryConvertibleMutable, ExpressibleByDictionaryLiteral {
    public typealias Key = Address
    public typealias Value = [SubscriberId]
    public typealias Map = [Key: Value]
    public var dictionary: Map
    public init(dictionary: Map) {
        self.dictionary = dictionary
    }
    
    mutating func add(subscriptionId: SubscriberId, for address: Address) {
        var existingSubscriptions = valueForKey(key: address, ifAbsent: { [SubscriberId]() })
        existingSubscriptions.append(subscriptionId)
        self[address] = existingSubscriptions
    }
    
    mutating func removeSubsciptionIds(for address: Address) {
        self.removeValue(forKey: address)
    }
}

public final class DefaultNodeInteraction: NodeInteraction {

    private let futureNodeConnection: Observable<NodeConnection>
    private let rpcClient: Observable<RPCClient>
    private var addressToSubscriberId: AddressToSubscriberId = [:]
    private var subscriptionsFromSubmit = [SubscriberId]()

    public init(_ nodeDiscovery: NodeDiscovery) {
        self.futureNodeConnection = DefaultNodeConnection.byNodeDiscovery(nodeDiscovery).map { $0 }
        self.rpcClient = futureNodeConnection.map { $0.rpcClient }
    }
}

// MARK: - NodeInteractionSubscribing
public extension DefaultNodeInteraction {
    
    /// TODO change this:
    // For each update we received 2 messages with `AtomSubscriptionUpdateSubscribe`
    // The first one, containing the atoms, having `isHead: false`
    // The second one, containing no atoms, having `isHead: true`
    // With the current solution we map those two `AtomSubscriptionUpdateSubscribe`
    // into two `onNext` events, which element is an array of `AtomUpdate`,
    // The first message resulting in a non empty array, the second message
    // being an empty array, which is kind of weird. Change this!
    func subscribe(to address: Address) -> Observable<[AtomUpdate]> {
        let id = SubscriptionIdIncrementingGenerator.next()
        addressToSubscriberId.add(subscriptionId: id, for: address)
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
        subscriptionsFromSubmit.append(id)
        return rpcClient.flatMap { $0.submit(atom: atom, subscriberId: id) }
            .assertSubscriptionStarted()
            .mapToUpdateTypeElseReturnEmpty(type: AtomSubscriptionUpdateSubmitAndSubscribe.self)
            .assertAtomGotStored()
        
    }
}

// MARK: - NodeInteractionUnsubscribing
public extension DefaultNodeInteraction {
    
    func unsubscribe(from address: Address) -> CompletableWanted {
        
        guard let subscriberIdsForAddress = addressToSubscriberId[address] else {
            return Observable.just(())
        }
        
        return unsubscribeAll(subscriptions: subscriberIdsForAddress) {
            self.addressToSubscriberId.removeSubsciptionIds(for: address)
        }
    }
    
    func unsubscribeAll() -> CompletableWanted {
        return Observable.merge(
            
            // Remove subscription using addresses
            Observable.from(addressToSubscriberId.keys.map {
                self.unsubscribe(from: $0)
            }).merge(),
            
            // Remove subscription from submissions
            self.unsubscribeAll(subscriptions: subscriptionsFromSubmit) {
                self.subscriptionsFromSubmit = []
            }
        )
    }
}

private extension DefaultNodeInteraction {
    
    typealias RemoveSingleReference = (SubscriberId) -> Void
    typealias RemoveAllReferences = () -> Void
    
    func unsubscribeAll(
        subscriptions: [SubscriberId],
        removeSingleReference: RemoveSingleReference? = nil,
        removeAllReferences: RemoveAllReferences? = nil
    ) -> CompletableWanted {
        
        return Observable.from(subscriptions.map {
            self.unsubscribe(subscription: $0, removeSingleReference: removeSingleReference)
        }).merge()
            .do(onNext: { removeAllReferences?() })
    }
    
    func unsubscribe(
        subscription: SubscriberId,
        removeSingleReference: RemoveSingleReference? = nil
    ) -> CompletableWanted {
        return rpcClient.flatMap {
            $0.unsubscribe(subscriberId: subscription).mapToVoid()
        }.do(onNext: { removeSingleReference?(subscription) })
    }
}

extension ObservableType {
    func mapToVoid() -> Observable<Void> {
        return map { _ in }
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
            if let start = atomSubscription.startOrCancel, start.success == false {
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
