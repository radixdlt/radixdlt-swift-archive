//
//  AtomToTokenTransferMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol AtomToTokenTransferMapper: AtomToSpecificExecutedActionMapper where ExecutedAction == TransferTokenAction {}

public final class DefaultAtomToTokenTransferMapper: AtomToTokenTransferMapper {
    public init() {}
}

public extension DefaultAtomToTokenTransferMapper {
    typealias ExecutedAction = TransferTokenAction
    func map(atom: Atom, account: Account) -> Observable<ExecutedAction> {
        implementMe()
    }
}
