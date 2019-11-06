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

    // TODO Combine can this be removed?
    private let _retainingVariableEpics: [RadixNetworkEpic]
    
    // swiftlint:disable function_body_length
    
    /// Initialises and **starts** the controller of the Radix Network (collection of Radix Nodes).
    public init(
        network: RadixNetwork = DefaultRadixNetwork.init(),
        initialNetworkState: RadixNetworkState = RadixNetworkState(),
        epics: [RadixNetworkEpic],
        nodeActionReducers: [SomeReducer<NodeAction>]
    ) {
        
        let networkStateSubject = CurrentValueSubject<RadixNetworkState, Never>(initialNetworkState)
        let nodeActionSubject = PassthroughSubject<NodeAction, Never>()

        let connectableReducedNodeActions = nodeActionSubject
            .handleEvents(
                receiveOutput: { action in
                    let currentNetworkState = networkStateSubject.value
                    
                    let nextNetworkState = network.reduce(
                        state: currentNetworkState,
                        action: action
                    )
                    
                    nodeActionReducers.forEach {
                        $0.reduce(action: action)
                    }
                    
                    if nextNetworkState != currentNetworkState {
                        networkStateSubject.send(nextNetworkState)
                    }
                }
            )
            .makeConnectable()

        let networkState = networkStateSubject.eraseToAnyPublisher()

        self.nodeActionSubject = nodeActionSubject
        self.networkStateSubject = networkStateSubject

        self.reducedNodeActions = connectableReducedNodeActions.eraseToAnyPublisher()
        self._retainingVariableEpics = epics

        // Then run Epics
        let updates: [AnyPublisher<NodeAction, Never>] = epics.map {
            $0.handle(
                actions: connectableReducedNodeActions.eraseToAnyPublisher(),
                networkState: networkState
            )
        }

        Publishers.MergeMany(updates).sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished: incorrectImplementation("Received unexpected `finish`, the epics should never finish")
                case .failure(let error):
                    // TODO Combine change `Failure` type of `networkStateSubject` to some new
                    // Error type for RadixNetworkEpics...
                    networkStateSubject.send(completion: .failure(error))
                }
            },
            receiveValue: { [unowned self] in self.dispatch(nodeAction: $0) }
        ).store(in: &cancellables)
        
        connectableReducedNodeActions.connect().store(in: &cancellables)
        
    }
    // swiftlint:enable function_body_length

}

public extension DefaultRadixNetworkController {
    
    func getActions() -> AnyPublisher<NodeAction, Never> {
        return reducedNodeActions
    }
    
    func dispatch(nodeAction: NodeAction) {
        nodeActionSubject.send(nodeAction)
    }

    func observeNetworkState() -> AnyPublisher<RadixNetworkState, Never> {
        networkStateSubject.eraseToAnyPublisher()
    }
    
    var currentNetworkState: RadixNetworkState {
        networkStateSubject.value
    }

}
