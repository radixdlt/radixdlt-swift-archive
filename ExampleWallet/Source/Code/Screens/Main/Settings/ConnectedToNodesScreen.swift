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
import Combine

import RadixSDK

import RxSwift

struct ConnectedToNodesScreen {

    // MARK: - Injected properties
    @EnvironmentObject private var radix: Radix

    // MARK: Stateful Properties
    @State private var connectToNodes = [Node]()

    // MARK: Other properites
    private let rxDisposeBag = RxSwift.DisposeBag()

    init() {

//        // Subscribe to change of address (when changing active account)
//        appModel.radixApplicationClient.observeConnectedToNodes
//            .subscribe(onNext: {
//                self.connectToNodes = $0
//            })
//            .disposed(by: rxDisposeBag)

        print("ConnectedToNodesScreen: fix me, subscribe to nodes")
    }
}

// MARK: - View
extension ConnectedToNodesScreen: View {
    var body: some View {
        List(connectToNodes) { node in
            Text(node.description)
        }
    }
}


extension Node: CustomStringConvertible {
    public var description: String {
        return "\(host.domain):\(host.port)"
    }
}

extension Node: Swift.Identifiable {
    public var id: Int { hashValue }
}
