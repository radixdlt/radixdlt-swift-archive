//
//  AtomToSpecificExecutedActionMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol BaseAtomToExecutedActionsMapper {
    func map<Action>(atom: Atom, toAction actionType: Action.Type, account: Account) -> Observable<Action>
}

public protocol AtomToSpecificExecutedActionMapper: BaseAtomToSpecificExecutedActionMapper {
    associatedtype ExecutedAction
    func map(atom: Atom, account: Account) -> Observable<ExecutedAction>
}

public extension AtomToSpecificExecutedActionMapper {
    func map<Action>(atom: Atom, toAction actionType: Action.Type, account: Account) -> Observable<Action> {
        assert(actionType == ExecutedAction.self, "action types should match")
        // swiftlint:disable:next force_cast
        return map(atom: atom, account: account).map { $0 as! Action }
    }
}
