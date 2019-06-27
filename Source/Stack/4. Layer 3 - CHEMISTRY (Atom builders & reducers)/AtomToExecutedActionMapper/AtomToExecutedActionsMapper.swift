//
//  AtomToSpecificExecutedActionMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol AtomToSpecificExecutedActionMapper: BaseAtomToSpecificExecutedActionMapper {
    associatedtype ExecutedAction
    func map(atom: Atom, account: Account) -> Observable<ExecutedAction>
}

public extension AtomToSpecificExecutedActionMapper {
    func map<Action>(atom: Atom, toActionType _: Action.Type, account: Account) -> Observable<Action> {
        return map(atom: atom, account: account).map {
            castOrKill(instance: $0, toType: Action.self)
        }
    }
}
