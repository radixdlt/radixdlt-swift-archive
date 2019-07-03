//
//  AtomSubmitting.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-23.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol AtomSubmitting {
    func pushAtom(_ atom: SignedAtom) -> Completable
}
