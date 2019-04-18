//
//  DefaultNodeInteraction.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-12.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public struct Subscriptions: DictionaryConvertibleMutable, ExpressibleByDictionaryLiteral {
    public typealias Key = SubscriberId
    public typealias Value = Observable<[AtomUpdate]>
    public typealias Map = [Key: Value]
    public var dictionary: Map
    public init(dictionary: Map) {
        self.dictionary = dictionary
    }
}

public struct PublicKeyHashIdToSubscriberId: DictionaryConvertibleMutable, ExpressibleByDictionaryLiteral {
    public typealias Key = Address
    public typealias Value = SubscriberId
    public typealias Map = [Key: Value]
    public var dictionary: Map
    public init(dictionary: Map) {
        self.dictionary = dictionary
    }
}

public final class DefaultNodeInteraction: NodeInteraction {

    private let nodeConnection: NodeConnection
    private var addressToSubscriberId: PublicKeyHashIdToSubscriberId = [:]
    private var subscriptions: Subscriptions = [:]

    public init(connectedToNode: NodeConnection) {
        self.nodeConnection = connectedToNode
    }
}

// MARK: - Concenience init
public extension DefaultNodeInteraction {
    convenience init(node: Node) {
        self.init(connectedToNode: DefaultNodeConnection(node: node))
    }
}

// MARK: - NodeInteraction
public extension DefaultNodeInteraction {
    
    func subscribe(to address: Address) -> Observable<[AtomUpdate]> {
        
        let subscriberId = reuseSubscriberIdElseCreateNew(for: address)
        return subscriptions.valueForKey(key: subscriberId) { [weak self] in
            guard let self = self else { return Observable.error(Error.deallocated) }
            return self.nodeConnection.rpcClient
                .subscribe(to: address, subscriberId: subscriberId)
                .ifFailedToStartSubscription(throw: Error.nodeNotifiedAboutFailureToSubscribe)
                .map { $0.update }.filterNil()
                .map { $0.subscriptionUpdate }.ifNilKill("Should only be subscription updates")
                .map { $0.toAtomUpdates() }
            }
    }
    
    func submit(atom: SignedAtom) -> Completable {
        let subscriberId = SubscriptionIdIncrementingGenerator.next()
        
        return nodeConnection.rpcClient
            .submit(atom: atom, subscriberId: subscriberId)
            .ifFailedToStartSubscription(throw: Error.nodeNotifiedAboutFailureToSubscribe)
            .asSingle().asCompletable()
    }
    
    func unsubscribe(from address: Address) -> Completable {
        implementMe
    }
    
    func unsubscribeAll() -> Completable {
        implementMe
    }
    
}

// MARK: - Subscriptions
private extension DefaultNodeInteraction {
    
    func reuseSubscriberIdElseCreateNew(for address: Address) -> SubscriberId {
        return addressToSubscriberId.valueForKey(key: address) {
            SubscriptionIdIncrementingGenerator.next()
        }
    }
}

// MARK: - Error
public extension DefaultNodeInteraction {
    enum Error: Swift.Error {
        case deallocated
        case nodeNotifiedAboutFailureToSubscribe
    }
}

extension ObservableType where E == AtomSubscription {
    func ifFailedToStartSubscription(throw error: Error) -> Observable<E> {
        return asObservable().flatMap { (atomSubscription: AtomSubscription) -> Observable<AtomSubscription> in
            if let start = atomSubscription.start, start.success == false {
                return Observable.error(error)
            } else {
                return Observable.just(atomSubscription)
            }
        }
    }
}
