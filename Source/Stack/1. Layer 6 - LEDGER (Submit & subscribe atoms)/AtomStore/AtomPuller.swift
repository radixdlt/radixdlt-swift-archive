/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation
import RxSwift

public protocol AtomPuller {
    func pull(address: Address) -> Observable<Any>
}

public final class DefaultAtomPuller: AtomPuller {
    
    private var requestCache = RequestCache()
    
    private let networkController: RadixNetworkController
    public init(networkController: RadixNetworkController) {
        self.networkController = networkController
    }
}

public extension DefaultAtomPuller {
    func pull(address: Address) -> Observable<Any> {
        return requestCache.valueForKey(key: address) {
            let fetchAtomsRequest = FetchAtomsActionRequest(address: address)
            return Observable.create { [weak self] observer in
                guard let `self` = self else {
                    observer.onCompleted()
                    return Disposables.create()
                }
                self.networkController.dispatch(nodeAction: fetchAtomsRequest)
                
                return Disposables.create {
                    let cancelRequest = FetchAtomsActionCancel(request: fetchAtomsRequest)
                    self.networkController.dispatch(nodeAction: cancelRequest)
                }
            }
        }.map { $0 }
    }
}

internal extension DefaultAtomPuller {
    struct RequestCache: DictionaryConvertibleMutable, ExpressibleByDictionaryLiteral {
        public typealias Key = Address
        public typealias Value = Observable<FetchAtomsAction>
        public typealias Map = [Key: Value]
        public var dictionary: Map
        public init(dictionary: Map) {
            self.dictionary = dictionary
        }
    }
}
