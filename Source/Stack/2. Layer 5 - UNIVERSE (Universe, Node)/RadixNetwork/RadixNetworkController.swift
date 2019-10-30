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
import Combine

public protocol RadixNetworkController {
    func dispatch(nodeAction: NodeAction)
    func getActions() -> AnyPublisher<NodeAction, Never>

    func observeNetworkState() -> AnyPublisher<RadixNetworkState, Never>
    var currentNetworkState: RadixNetworkState { get }
}

public extension RadixNetworkController {
    var connectedNodes: AnyPublisher<[RadixNodeState], Never> {
        observeNetworkState().map {
            $0.connectedNodes()
        }.eraseToAnyPublisher()
    }
}

public final class DefaultRadixNetworkController: RadixNetworkController {
    
    // MARK: Private Properties
    private let networkStateSubject: CurrentValueSubject<RadixNetworkState, Never>
    private let nodeActionSubject: PassthroughSubject<NodeAction, Never>
    private let reducedNodeActions: AnyPublisher<NodeAction, Never>

    private var cancellables = Set<AnyCancellable>()

    private let _retainingVariableEpics: [RadixNetworkEpic]
    
    public init(
        network: RadixNetwork = DefaultRadixNetwork.init(),
        initialNetworkState: RadixNetworkState = RadixNetworkState(),
        epics: [RadixNetworkEpic],
        reducers: [SomeReducer<NodeAction>]
    ) {
        
//        let networkStateSubject = CurrentValueSubject(initialNetworkState)
//        let nodeActionSubject = PassthroughSubject<NodeAction>()
//
//        let reducedNodeActions = nodeActionSubject.eraseToAnyPublisher().do(onNext: { action in
//            let state = try networkStateSubject.value
//            let nextState = network.reduce(state: state, action: action)
//            reducers.forEach {
//                $0.reduce(action: action)
//            }
//
//            if nextState != state {
//                networkStateSubject.send(nextState)
//            }
//        }).publish()
//
//        let networkState = networkStateSubject.eraseToAnyPublisher()
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
        nodeActionSubject.send(nodeAction)
    }
    
}

public extension DefaultRadixNetworkController {
    func observeNetworkState() -> CombineObservable<RadixNetworkState> {
        networkStateSubject.eraseToAnyPublisher()
    }
    
    var currentNetworkState: RadixNetworkState {
        networkStateSubject.value
    }

}
