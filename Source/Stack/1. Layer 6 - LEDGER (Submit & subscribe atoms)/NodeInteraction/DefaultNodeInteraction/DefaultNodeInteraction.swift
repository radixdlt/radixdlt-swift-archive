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

// swiftlint:disable colon opening_brace

public final class DefaultNodeInteraction:
    NodeInteraction,
    Throwing
{

    // swiftlint:enable colon opening_brace

    private let futureNodeConnection: Observable<NodeConnection>
    private let rpcClient: Observable<RPCClient>
    private var addressToSubscriberId: AddressToSubscriberId = [:]
    private var subscriptionsFromSubmit = [SubscriberId]()
    
    public init(withNode node: Observable<Node>) {
        self.futureNodeConnection = node.map { DefaultNodeConnection(node: $0) } // DefaultNodeConnection.byNodeDiscovery(nodeDiscovery).map { $0 }
        self.rpcClient = futureNodeConnection.map { $0.rpcClient }
    }
}

public extension DefaultNodeInteraction {
    
    convenience init(node: Node) {
        self.init(withNode: .just(node))
    }
}

enum NodeFindingResult {
    public typealias FindingResult = Result<NodeInteraction, SpecificNode.UnsuitableReason>
    
    case anyNode(DefaultNodeInteraction)
    case specificNode(SpecificNode)
    
    public enum SpecificNode {
        case connectedToSpecifiedNode(DefaultNodeInteraction)
        case didNotConnectToSpecifiedNodeFellbackTo(DefaultNodeInteraction, reason: UnsuitableReason)
        case didNotConnectToSpecifiedNodeError(reason: UnsuitableReason)
        
        public enum UnsuitableReason: Swift.Error {
            case offline, shardMismatch, wrongUniverse
        }
    }
    
    var result: FindingResult {
        switch self {
        case .anyNode(let nodeInteraction): return .success(nodeInteraction)
        case .specificNode(let resultConnectingToSpecificNode):
            switch resultConnectingToSpecificNode {
            case .connectedToSpecifiedNode(let nodeInteraction): return .success(nodeInteraction)
            case .didNotConnectToSpecifiedNodeFellbackTo(let fallbackNodeInteraction, _): return .success(fallbackNodeInteraction)
            case .didNotConnectToSpecifiedNodeError(let reason): return .failure(reason)
            }
        }
    }
}

// MARK: - NodeInteractionSubscribing
public extension DefaultNodeInteraction {
    
    /// TODO change this:
    // For each update we received 2 messages with `AtomSubscriptionUpdateSubscribe`
    // The first one, containing the atoms, having `isHead: false`
    // The second one, containing no atoms, having `isHead: true`
    // With the current solution we map those two `AtomSubscriptionUpdateSubscribe`
    // into two `onNext` events, which element is an array of `AtomObservation`,
    // The first message resulting in a non empty array, the second message
    // being an empty array, which is kind of weird. Change this!
    func subscribe(to address: Address) -> Observable<[AtomObservation]> {
        let id = SubscriptionIdIncrementingGenerator.next()
        addressToSubscriberId.add(subscriptionId: id, for: address)
        return rpcClient.flatMapLatest { $0.subscribe(to: address, subscriberId: id) }
            .assertSubscriptionStarted()
            .mapToUpdateTypeElseReturnEmpty(type: AtomSubscriptionUpdateSubscribe.self)
            .map { $0.toAtomObservation() }
    }
}

// MARK: - NodeInteractionSubmitting
public extension DefaultNodeInteraction {
    
    func submit(atom: SignedAtom) -> CompletableWanted {
        return rpcClient.flatMap { $0.submit(atom: atom) }
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
public enum NodeInteractionError: Swift.Error, Equatable {
    case failedToStartSubscribeToNode
    case atomNotStored(state: AtomSubscriptionUpdateSubmitAndSubscribe.State)
}

public extension DefaultNodeInteraction {
    typealias Error = NodeInteractionError
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
            .ifNilReturnEmpty()
            .map { $0.mapTo(type: U.self) }
            .ifNilReturnEmpty()
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
