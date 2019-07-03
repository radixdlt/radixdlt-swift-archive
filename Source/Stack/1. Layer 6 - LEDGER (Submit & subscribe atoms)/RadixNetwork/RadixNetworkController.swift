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
    var networkState: Observable<RadixNetworkState> { get }
    
    func dispatch(nodeAction: NodeAction)
    func getActions() -> Observable<NodeAction>
}

public final class DefaultRadixNetworkController: RadixNetworkController {
    
    private let networkStateSubject: BehaviorSubject<RadixNetworkState>
    private let nodeActionSubject: PublishSubject<NodeAction>
    private let reducedNodeActions: Observable<NodeAction>
    
    public let networkState: Observable<RadixNetworkState>
    private let disposeBag = DisposeBag()

    public init(
        network: RadixNetwork = DefaultRadixNetwork.init(),
        initialNetworkState: RadixNetworkState = RadixNetworkState(),
        epics: [RadixNetworkEpic],
        reducers: [SomeReducer<NodeAction>]
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
        }).publish()
        
        let networkState = networkStateSubject.asObservable()
        
        self.nodeActionSubject = nodeActionSubject
        self.networkStateSubject = networkStateSubject
        self.networkState = networkState
        self.reducedNodeActions = reducedNodeActions
        
        // Then run Epics
        let updates: [Observable<NodeAction>] = epics.map { epic in
            epic.epic(actions: reducedNodeActions, networkState: networkState)
        }
        
        Observable.merge(updates).subscribe(
            onNext: { [unowned self] in self.dispatch(nodeAction: $0) },
            onError: {
                log.error("Error: \($0)")
                networkStateSubject.onError($0)
                
        }).disposed(by: disposeBag)
        
        reducedNodeActions.connect().disposed(by: disposeBag)
    }
}

public extension DefaultRadixNetworkController {
    
    func getActions() -> Observable<NodeAction> {
        return reducedNodeActions
    }
    
    func dispatch(nodeAction: NodeAction) {
        nodeActionSubject.onNext(nodeAction)
    }
    
}

//private extension DefaultRadixNetworkController {
//
//
//
//    var universeConfig: UniverseConfig {
//        return nodeFinding.config
//    }
//
//    func nodeInteraction(for address: Address) -> Observable<NodeInteraction> {
//        return nodeInteraction(nodeFinding: nodeFinding, for: address)
//    }
//
//    func nodeInteraction(nodeFinding: NodeFindingg, for address: Address) -> Observable<NodeInteraction> {
//        let suitableNodes = discovery.findNodesSuitable(for: address, inUniverseHavingConfig: universeConfig, strategyWhenUnsuitable: nodeFinding.strategyWhenAllNodesAreUnsuitable)
//
//        return suitableNodes.map { (nodes: [Node]) -> Node in
//            guard let first = nodes.first else {
//                throw NodeDiscoveryError.foundZeroNodes
//            }
//            return first
//            }.map {
//                DefaultNodeInteraction(node: $0)
//            }.map { $0 }
//    }
//}

//public extension DefaultRadixNetworkController {
//    struct NodeInteractionForAddress: DictionaryConvertibleMutable, ExpressibleByDictionaryLiteral {
//        public typealias Key = Address
//        public typealias Value = [NodeInteraction]
//        public typealias Map = [Key: Value]
//        public var dictionary: Map
//        public init(dictionary: Map) {
//            self.dictionary = dictionary
//        }
//
//        mutating func add(interaction: NodeInteraction, for address: Address) {
//            var existingInteractions = valueForKey(key: address, ifAbsent: { [NodeInteraction]() })
//            existingInteractions.append(interaction)
//            self[address] = existingInteractions
//        }
//
//        mutating func removeInteractions(for address: Address) {
//            self.removeValue(forKey: address)
//        }
//    }
//}
