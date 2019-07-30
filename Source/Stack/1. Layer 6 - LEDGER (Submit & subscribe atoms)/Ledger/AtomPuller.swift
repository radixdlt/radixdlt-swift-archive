//
//  Ledger.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

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
    
    deinit {
        log.warning("🧨")
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
