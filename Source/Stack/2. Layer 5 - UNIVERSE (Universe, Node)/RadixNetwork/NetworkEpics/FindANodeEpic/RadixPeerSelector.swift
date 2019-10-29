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

public final class RadixPeerSelector {
    // Swift 5.2: Change to `callAsFunction`:
    // https://github.com/apple/swift-evolution/blob/master/proposals/0253-callable.md
    public typealias PeerSelector = (NonEmptySet<Node>) -> Node
    public let selectPeer: PeerSelector
    
    init(selectPeer: @escaping PeerSelector) {
        self.selectPeer = selectPeer
    }
}

public extension RadixPeerSelector {
    
    static var `default`: RadixPeerSelector { .random }
    
    static var random: RadixPeerSelector {
        .init { $0.randomElement() }
    }
    
    static var first: RadixPeerSelector {
        .init { $0.first }
    }
}
