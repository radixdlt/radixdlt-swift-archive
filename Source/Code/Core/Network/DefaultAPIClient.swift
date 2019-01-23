//
//  DefaultAPIClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultAPIClient: APIClient {
    public let networkState = BehaviorSubject<NetworkState>(value: [:])
    public let nodeActions = PublishSubject<NodeAction>()
    
}

public extension DefaultAPIClient {
    
    func fetchAtoms(for address: Address) -> Observable<AtomObservation> {
        implementMe
    }
    
    func submit(atom: Atom) -> Observable<SubmitAtomAction> {
        implementMe
    }
}
