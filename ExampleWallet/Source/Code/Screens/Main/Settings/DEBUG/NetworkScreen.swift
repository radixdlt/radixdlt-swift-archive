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

import SwiftUI
import RadixSDK

struct NetworkScreen {
    @EnvironmentObject private var viewModel: ViewModel
}

// MARK: View
extension NetworkScreen: View {
    var body: some View {
        
        Form {
            makeList(nodes: viewModel.readyNodes, header: "Ready nodes")
            makeList(nodes: viewModel.unreadyNodes, header: "Unready nodes")
        }
      
    }
}

private extension NetworkScreen {
    func makeList(nodes: [RadixNodeState], header: String) -> some View {
        Group {
            if nodes.isEmpty {
                EmptyView().eraseToAny()
            } else {
                Section(header: Text(header)) {
                    List(nodes) { nodeState in
                        NavigationLink(destination: NodeInfoScreen(nodeState: nodeState)) {
                            Text("\(nodeState.node.id)")
                        }
                    }
                }.eraseToAny()
            }
        }
    }
}

import Combine
extension NetworkScreen {
    final class ViewModel: ObservableObject {
        @Published var networkState: RadixNetworkState = .init()
        
        private var cancellables = Set<AnyCancellable>()
        
        init(networkStatePublisher: AnyPublisher<RadixNetworkState, Never>) {
            networkStatePublisher.sink(receiveValue: {
                self.networkState = $0
            }).store(in: &cancellables)
        }
    }
}

extension NetworkScreen.ViewModel {
    convenience init(radixDebug: Radix.Debug) {
        self.init(networkStatePublisher: radixDebug.networkState)
    }
}

extension NetworkScreen.ViewModel {
    var readyNodes: [RadixNodeState] { networkState.readyNodes }
    var unreadyNodes: [RadixNodeState] { networkState.unreadyNodes }
}

struct NodeInfoScreen {
    let nodeState: RadixNodeState
}

extension NodeInfoScreen: View {
    var body: some View {
        Text("\(nodeState.debugDescription)")
    }
}
