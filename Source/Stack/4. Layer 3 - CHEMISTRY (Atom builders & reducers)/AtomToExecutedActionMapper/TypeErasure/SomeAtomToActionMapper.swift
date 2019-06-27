//
//  SomeAtomToExecutedActionMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public struct SomeAtomToExecutedActionMapper<ExecutedAction>: AtomToSpecificExecutedActionMapper {
    
    private let _map: (Atom, Account) -> Observable<ExecutedAction>
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: AtomToSpecificExecutedActionMapper, Concrete.ExecutedAction == ExecutedAction {
        self._map = { concrete.map(atom: $0, account: $1) }
    }
    
    public init(any: AnyAtomToExecutedActionMapper) throws {
        guard any.matches(actionType: ExecutedAction.self) else {
            throw Error.actionTypeMismatch
        }
        self._map = { any.map(atom: $0, toActionType: ExecutedAction.self, account: $1) }
    }
}

public extension SomeAtomToExecutedActionMapper {
    
    enum Error: Int, Swift.Error, Equatable {
        case actionTypeMismatch
    }
    
    func map(atom: Atom, account: Account) -> Observable<ExecutedAction> {
        return _map(atom, account)
    }
}
