//
//  AtomStatusChecking.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol AtomStatusChecking {
    func statusOfAtom(withIdentifier atomIdentifier: AtomIdentifier) -> Single<AtomStatus>
}
