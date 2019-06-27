//
//  RadixNetworkController.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol RadixNetworkController {
    func dispatch(nodeAction: NodeAction)
    var networkState: Observable<RadixNetworkState> { get }
    
    func getActions() -> Observable<NodeAction>

    func connectToNode(nodeFinding: NodeFindingg, address: Address) -> Completable
    func connectToNode(address: Address) -> Completable
}

public final class DefaultRadixNetworkController: RadixNetworkController {
//    public private(set) var network: RadixNetwork
    
//    private let nodeFindingStrategy: NodeFindingStrategy
    private let nodeFinding: NodeFindingg
    private var nodeInteractions = NodeInteractionForAddress()
    
    private let networkStateSubject: BehaviorSubject<RadixNetworkState>
    private let nodeActionSubject: PublishSubject<NodeAction>
    private let reducedNodeActions: Observable<NodeAction>
    
//    public init(
//        network: RadixNetwork = DefaultRadixNetwork.init(),
//        nodeFindingStrategy: NodeFindingStrategy
//    ) {
//        self.network = network
//        self.nodeFindingStrategy = nodeFindingStrategy
//    }
    
    public init(
        nodeFinding: NodeFindingg,
        reducers: [SomeReducer<NodeAction>],
        network: RadixNetwork = DefaultRadixNetwork.init(),
        initialNetworkState: RadixNetworkState = RadixNetworkState()
    ) {
        let networkStateSubject = BehaviorSubject(value: initialNetworkState)
        let nodeActionSubject = PublishSubject<NodeAction>()
        
        let reducedNodeActions = nodeActionSubject.asObservable().do(onNext: { action in
            let state = try networkStateSubject.value()
            let nextState = network.reduce(state: state, action: action)
            reducers.forEach { $0.reduce(action: action) }
            if nextState != state {
                networkStateSubject.onNext(nextState)
            }
        })
        
        self.nodeFinding = nodeFinding
        self.nodeActionSubject = nodeActionSubject
        self.networkStateSubject = networkStateSubject
        self.reducedNodeActions = reducedNodeActions
    }
}

public extension DefaultRadixNetworkController {
    
    func getActions() -> Observable<NodeAction> {
        return reducedNodeActions
    }
    
    func dispatch(nodeAction: NodeAction) {
        nodeActionSubject.onNext(nodeAction)
    }
    
    func connectToNode(nodeFinding: NodeFindingg, address: Address) -> Completable {
        return nodeInteraction(nodeFinding: nodeFinding, for: address).asSingle().asCompletable()
    }
    
    func connectToNode(address: Address) -> Completable {
        return connectToNode(nodeFinding: self.nodeFinding, address: address)
    }
    
    var networkState: Observable<RadixNetworkState> {
        return networkStateSubject.asObservable()
    }
    
}

private extension DefaultRadixNetworkController {
    
    var discovery: SuitableNodeDiscovering {
        return nodeFinding.discovery
    }
    
    var universeConfig: UniverseConfig {
        return nodeFinding.config
    }
    
    func nodeInteraction(for address: Address) -> Observable<NodeInteraction> {
        return nodeInteraction(nodeFinding: nodeFinding, for: address)
    }
    
    func nodeInteraction(nodeFinding: NodeFindingg, for address: Address) -> Observable<NodeInteraction> {
        let suitableNodes = discovery.findNodesSuitable(for: address, inUniverseHavingConfig: universeConfig, strategyWhenUnsuitable: nodeFinding.strategyWhenAllNodesAreUnsuitable)
        
        return suitableNodes.map { (nodes: [Node]) -> Node in
            guard let first = nodes.first else {
                throw NodeDiscoveryError.foundZeroNodes
            }
            return first
            }.map {
                DefaultNodeInteraction(node: $0)
            }.map { $0 }
    }
}

public extension DefaultRadixNetworkController {
    struct NodeInteractionForAddress: DictionaryConvertibleMutable, ExpressibleByDictionaryLiteral {
        public typealias Key = Address
        public typealias Value = [NodeInteraction]
        public typealias Map = [Key: Value]
        public var dictionary: Map
        public init(dictionary: Map) {
            self.dictionary = dictionary
        }
        
        mutating func add(interaction: NodeInteraction, for address: Address) {
            var existingInteractions = valueForKey(key: address, ifAbsent: { [NodeInteraction]() })
            existingInteractions.append(interaction)
            self[address] = existingInteractions
        }
        
        mutating func removeInteractions(for address: Address) {
            self.removeValue(forKey: address)
        }
    }
}
