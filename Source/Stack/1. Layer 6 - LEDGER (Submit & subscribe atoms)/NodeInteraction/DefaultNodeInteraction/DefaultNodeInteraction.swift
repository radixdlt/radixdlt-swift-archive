////
////  DefaultNodeInteraction.swift
////  RadixSDK iOS
////
////  Created by Alexander Cyon on 2019-04-12.
////  Copyright © 2019 Radix DLT. All rights reserved.
////
//
//import Foundation
//import RxSwift
//
//public struct AddressToSubscriberId: DictionaryConvertibleMutable, ExpressibleByDictionaryLiteral {
//    public typealias Key = Address
//    public typealias Value = [SubscriberId]
//    public typealias Map = [Key: Value]
//    public var dictionary: Map
//    public init(dictionary: Map) {
//        self.dictionary = dictionary
//    }
//    
//    mutating func add(subscriptionId: SubscriberId, for address: Address) {
//        var existingSubscriptions = valueForKey(key: address, ifAbsent: { [SubscriberId]() })
//        existingSubscriptions.append(subscriptionId)
//        self[address] = existingSubscriptions
//    }
//    
//    mutating func removeSubsciptionIds(for address: Address) {
//        self.removeValue(forKey: address)
//    }
//}
//
//// swiftlint:disable colon opening_brace
//
//public final class DefaultNodeInteraction:
//    NodeInteraction,
//    Throwing
//{
//
//    // swiftlint:enable colon opening_brace
//
//    private let futureNodeConnection: Observable<NodeConnection>
//    private let rpcClient: Observable<RPCClient>
//    private var addressToSubscriberId: AddressToSubscriberId = [:]
//    private var subscriptionsFromSubmit = [SubscriberId]()
//    
//    public init(withNode node: Observable<Node>) {
//        self.futureNodeConnection = node.map { DefaultNodeConnection(node: $0) } // DefaultNodeConnection.byNodeDiscovery(nodeDiscovery).map { $0 }
//        self.rpcClient = futureNodeConnection.map { $0.rpcClient }
//    }
//}
//
//public extension DefaultNodeInteraction {
//    
//    convenience init(node: Node) {
//        self.init(withNode: .just(node))
//    }
//}
//
//
//
//// MARK: - NodeInteractionSubscribing
//public extension DefaultNodeInteraction {
//    
//    /// TODO change this:
//    // For each update we received 2 messages with `AtomSubscriptionUpdateSubscribe`
//    // The first one, containing the atoms, having `isHead: false`
//    // The second one, containing no atoms, having `isHead: true`
//    // With the current solution we map those two `AtomSubscriptionUpdateSubscribe`
//    // into two `onNext` events, which element is an array of `AtomObservation`,
//    // The first message resulting in a non empty array, the second message
//    // being an empty array, which is kind of weird. Change this!
//    func subscribe(to address: Address) -> Observable<[AtomObservation]> {
//        fatalError("should not be used")
////        let id = SubscriptionIdIncrementingGenerator.next()
////        addressToSubscriberId.add(subscriptionId: id, for: address)
////        return rpcClient.flatMapLatest { $0.subscribe(to: address, subscriberId: id) }
////            .assertSubscriptionStarted()
////            .mapToUpdateTypeElseReturnEmpty(type: AtomSubscriptionUpdateSubscribe.self)
////            .map { $0.toAtomObservation() }
//    }
//}
//
//// MARK: - NodeInteractionSubmitting
//public extension DefaultNodeInteraction {
//    
//    func submit(atom: SignedAtom) -> Completable {
//        return rpcClient.flatMapCompletable { $0.pushAtom(atom) }
//    }
//}
//
//// MARK: - NodeInteractionUnsubscribing
//public extension DefaultNodeInteraction {
//    
//    func unsubscribe(from address: Address) -> Completable {
//        
//        guard let subscriberIdsForAddress = addressToSubscriberId[address] else {
//            return Completable.completed()
//        }
//        
//        return unsubscribeAll(subscriptions: subscriberIdsForAddress) {
//            self.addressToSubscriberId.removeSubsciptionIds(for: address)
//        }
//    }
//    
//    func unsubscribeAll() -> Completable {
//        return Completable.merge(
//            // Remove subscription using addresses
//            addressToSubscriberId.keys.map {
//                self.unsubscribe(from: $0)
//            }
//        ).andThen(
//            // Remove subscription from submissions
//            self.unsubscribeAll(subscriptions: subscriptionsFromSubmit) {
//                self.subscriptionsFromSubmit = []
//            }
//        )
//    }
//}
//
//private extension DefaultNodeInteraction {
//    
//    typealias RemoveSingleReference = (SubscriberId) -> Void
//    typealias RemoveAllReferences = () -> Void
//    
//    func unsubscribeAll(
//        subscriptions: [SubscriberId],
//        removeSingleReference: RemoveSingleReference? = nil,
//        removeAllReferences: RemoveAllReferences? = nil
//    ) -> Completable {
//        
//        return Completable.merge(
//            subscriptions.map {
//                self.unsubscribe(subscription: $0, removeSingleReference: removeSingleReference)
//            }
//            ).do(onCompleted: {
//                removeAllReferences?()
//            })
//    }
//    
//    func unsubscribe(
//        subscription: SubscriberId,
//        removeSingleReference: RemoveSingleReference? = nil
//    ) -> Completable {
//        return rpcClient.flatMapCompletable {
//            $0.cancelAtomsSubscription(subscriberId: subscription)
//        }
////            .do(onNext: { removeSingleReference?(subscription) })
//    }
//}
//
//
//// MARK: - Error
////public enum NodeInteractionError: Swift.Error, Equatable {
////    case failedToStartSubscribeToNode
////    case atomNotStored(state: AtomSubscriptionUpdateSubmitAndSubscribe.State)
////}
//
//public extension DefaultNodeInteraction {
//    typealias Error = NodeInteractionError
//}
//
//// MARK: - Observable + AtomSubscription
//extension ObservableType where Element == AtomSubscription {
//    func assertSubscriptionStarted() -> Observable<Element> {
//        return asObservable().flatMap { (atomSubscription: AtomSubscription) -> Observable<AtomSubscription> in
//            if let start = atomSubscription.startOrCancel, start.success == false {
//                return Observable.error(DefaultNodeInteraction.Error.failedToStartSubscribeToNode)
//            } else {
//                return Observable.just(atomSubscription)
//            }
//        }
//    }
//}
