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

    private let _retainingVariableEpics: [RadixNetworkEpic]
    
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
            reducers.forEach {
                $0.reduce(action: action)
            }
   
            if nextState != state {
                log.verbose("Current Network state: \(state)")
                log.verbose("Next Network state: \(nextState)")
                networkStateSubject.onNext(nextState)
            }
        }).publish()
        
        let networkState = networkStateSubject.asObservable()
        
        self.nodeActionSubject = nodeActionSubject
        self.networkStateSubject = networkStateSubject
        self.networkState = networkState
        self.reducedNodeActions = reducedNodeActions
        self._retainingVariableEpics = epics
        
        // Then run Epics
        let updates: [Observable<NodeAction>] = epics.map { epic in
            epic.epic(actions: reducedNodeActions, networkState: networkState)
        }
        
        Observable.merge(updates).subscribe(
            onNext: { [unowned self] in
                self.dispatch(nodeAction: $0)
            },
            onError: {
                incorrectImplementation("Error: \($0)")
//                log.error("Error: \($0)")
//                networkStateSubject.onError($0)
            }
        ).disposed(by: disposeBag)
        
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
