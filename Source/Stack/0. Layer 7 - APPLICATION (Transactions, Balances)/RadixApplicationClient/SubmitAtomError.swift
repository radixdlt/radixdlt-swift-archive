//
//  SubmitAtomError.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

// chose either this or `AtomSubscriptionUpdateSubmitAndSubscribe.State`
public enum SubmitAtomError: Swift.Error {
    case failed, collision, illagalState, unsuitablePeer, validationError, unknownError
}
