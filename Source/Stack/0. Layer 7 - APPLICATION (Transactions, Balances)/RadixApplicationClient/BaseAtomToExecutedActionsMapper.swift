//
//  BaseAtomToSpecificExecutedActionMapper.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol BaseAtomToSpecificExecutedActionMapper {
    func map<Action>(atom: Atom, toAction actionType: Action.Type, account: Account) -> Observable<Action>
}
