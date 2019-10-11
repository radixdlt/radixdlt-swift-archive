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
import RxSwift
import Combine

public protocol RadixNetworkController {
    func dispatch(nodeAction: NodeAction)
    func getActions() -> CombineObservable<NodeAction>

    func observeNetworkState() -> CombineObservable<RadixNetworkState>
    var currentNetworkState: RadixNetworkState { get }
}

public extension RadixNetworkController {
    var readyNodes: CombineObservable<[RadixNodeState]> {
        observeNetworkState().map {
            $0.readyNodes
        }.eraseToAnyPublisher()
    }
}

public final class DefaultRadixNetworkController: RadixNetworkController {
    
    // MARK: Private Properties
    private let networkStateSubject: CurrentValueSubjectNoFail<RadixNetworkState>
    private let nodeActionSubject: PassthroughSubjectNoFail<NodeAction>
    private let reducedNodeActions: CombineObservable<NodeAction>

    private let disposeBag = DisposeBag()

    private let _retainingVariableEpics: [RadixNetworkEpic]
    
    public init(
        network: RadixNetwork = DefaultRadixNetwork.init(),
        initialNetworkState: RadixNetworkState = RadixNetworkState(),
        epics: [RadixNetworkEpic],
        reducers: [SomeReducer<NodeAction>]
    ) {
        
//        let networkStateSubject = CurrentValueSubjectNoFail(initialNetworkState)
//        let nodeActionSubject = PassthroughSubjectNoFail<NodeAction>()
//
//        let reducedNodeActions = nodeActionSubject.asObservable().do(onNext: { action in
//            let state = try networkStateSubject.value
//            let nextState = network.reduce(state: state, action: action)
//            reducers.forEach {
//                $0.reduce(action: action)
//            }
//
//            if nextState != state {
//                networkStateSubject.onNext(nextState)
//            }
//        }).publish()
//
//        let networkState = networkStateSubject.asObservable()
//
//        self.nodeActionSubject = nodeActionSubject
//        self.networkStateSubject = networkStateSubject
////        self.networkState = networkState
//        self.reducedNodeActions = reducedNodeActions
//        self._retainingVariableEpics = epics
//
//        // Then run Epics
//        let updates: [CombineObservable<NodeAction>] = epics.map { epic in
//            epic.epic(actions: reducedNodeActions, networkState: networkState)
//        }
//
//        CombineObservable.merge(updates).subscribe(
//            onNext: { [unowned self] in
//                self.dispatch(nodeAction: $0)
//            },
//            onError: {
//                networkStateSubject.onError($0)
//            }
//        ).disposed(by: disposeBag)
//
//        reducedNodeActions.connect().disposed(by: disposeBag)
        
        combineMigrationInProgress()
    }
}

public extension DefaultRadixNetworkController {
    
    func getActions() -> CombineObservable<NodeAction> {
        return reducedNodeActions
    }
    
    func dispatch(nodeAction: NodeAction) {
        nodeActionSubject.onNext(nodeAction)
    }
    
}

public extension DefaultRadixNetworkController {
    func observeNetworkState() -> CombineObservable<RadixNetworkState> {
        return networkStateSubject.asObservable()
    }
    
    var currentNetworkState: RadixNetworkState {
        networkStateSubject.value
    }

}
