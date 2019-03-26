//
//  DefaultAPIClient.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public final class DefaultAPIClient: APIClient {}

public extension DefaultAPIClient {
    
    func pull(from address: Address) -> Observable<AtomObservation> {
        implementMe
    }
    
    func submit(atom: Atom) -> Observable<SubmitAtomAction> {
        implementMe
    }
}
