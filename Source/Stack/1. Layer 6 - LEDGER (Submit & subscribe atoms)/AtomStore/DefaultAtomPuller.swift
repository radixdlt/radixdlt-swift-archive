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

public final class DefaultAtomPuller: AtomPuller {
    
    // TODO: change from `var` to `let`, when Swift bug SE-11783 has been fixed: https://bugs.swift.org/browse/SR-11783
    private var requestCache: RequestCache
    
    private let nodeActionsDispatcher: NodeActionsDispatcher
    
    public init(
        requestCache: RequestCache = [:],
        nodeActionsDispatcher: NodeActionsDispatcher
    ) {
        self.requestCache = requestCache
        self.nodeActionsDispatcher = nodeActionsDispatcher
    }
}

public extension DefaultAtomPuller {
    convenience init(networkController: RadixNetworkController) {
        self.init(nodeActionsDispatcher: .usingNetworkController(networkController))
    }
}

// MARK: AtomPuller
public extension DefaultAtomPuller {
    func pull(address: Address) -> Cancellable {
        
        return requestCache.valueForKey(key: address) {
            let fetchAtomsRequest = FetchAtomsActionRequest(address: address)
            self.nodeActionsDispatcher.dispatchNodeAction(fetchAtomsRequest)
            
            return AnyCancellable {
                let cancelRequest = FetchAtomsActionCancel(request: fetchAtomsRequest)
                self.nodeActionsDispatcher.dispatchNodeAction(cancelRequest)
            }
            
        }
    }
}

// MARK:  - RequestCache
public extension DefaultAtomPuller {
    final class RequestCache: DictionaryConvertibleMutable, ExpressibleByDictionaryLiteral {
        public typealias Key = Address
        public typealias Value = Cancellable
        public typealias Map = [Key: Value]
        public var dictionary: Map
        public init(dictionary: Map) {
            self.dictionary = dictionary
        }
    }
}
