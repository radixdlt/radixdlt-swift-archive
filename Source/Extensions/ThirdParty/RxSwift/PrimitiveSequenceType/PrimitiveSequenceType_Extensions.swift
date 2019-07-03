//
//  PrimitiveSequenceType_Extensions.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-07-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

extension PrimitiveSequenceType where Self: ObservableConvertibleType {
    
    func ignoreElements() -> Completable {
        return asObservable().ignoreElements()
    }
}
