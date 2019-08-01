//
//  AnyAtomToExecutedActionMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public struct AnyAtomToExecutedActionMapper: BaseAtomToSpecificExecutedActionMapper {
    
    private let _actionType: () -> Any.Type
    private let _matchesType: (Any.Type) -> Bool
    private let _map: (Atom, Any.Type, Account) -> Observable<Any>
    
    public init<Concrete>(_ concrete: Concrete) where Concrete: AtomToSpecificExecutedActionMapper {
        self._actionType = { Concrete.SpecificExecutedAction.self }
        self._matchesType = { return $0 == Concrete.SpecificExecutedAction.self }
        self._map = {
            typeErasureExpects(type: $1, toBe: Concrete.SpecificExecutedAction.Type.self)
            return concrete.map(atom: $0, toActionType: Concrete.SpecificExecutedAction.self, account: $2).map { $0 }
        }
    }
}

public extension AnyAtomToExecutedActionMapper {
    func map<Action>(atom: Atom, toActionType _: Action.Type, account: Account) -> Observable<Action> where Action: ExecutedAction {
        
        return self._map(atom, Action.self, account).map {
            return castOrKill(instance: $0, toType: Action.self)
        }
    }
    
    func matches<Action>(actionType: Action.Type) -> Bool {
        return _matchesType(actionType)
    }
    
    var actionType: Any.Type {
        return _actionType()
    }
}
