//
//  SomeAtomToExecutedActionMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public struct SomeAtomToExecutedActionMapper<SpecificExecutedAction>: AtomToSpecificExecutedActionMapper where SpecificExecutedAction: ExecutedAction {
    
    private let _map: (Atom, Account) -> Observable<SpecificExecutedAction>
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: AtomToSpecificExecutedActionMapper, Concrete.SpecificExecutedAction == SpecificExecutedAction {
        self._map = { concrete.map(atom: $0, account: $1) }
    }
    
    public init(any: AnyAtomToExecutedActionMapper) throws {
        guard any.matches(actionType: SpecificExecutedAction.self) else {
            throw Error.actionTypeMismatch
        }
        self._map = { any.map(atom: $0, toActionType: SpecificExecutedAction.self, account: $1) }
    }
}

public extension SomeAtomToExecutedActionMapper {
    
    enum Error: Int, Swift.Error, Equatable {
        case actionTypeMismatch
    }
    
    func map(atom: Atom, account: Account) -> Observable<SpecificExecutedAction> {
        return _map(atom, account)
    }
}
