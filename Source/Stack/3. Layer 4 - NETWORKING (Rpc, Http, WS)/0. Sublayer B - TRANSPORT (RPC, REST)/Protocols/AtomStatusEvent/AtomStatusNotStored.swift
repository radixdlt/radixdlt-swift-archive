//
//  AtomStatusNotStored.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-08-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// Similar to AtomStatus, but without `stored` case
enum AtomStatusNotStored: Swift.Error, Equatable {
    case doesNotExist
    
    case evictedConflictLoser
    case pendingConstraintMachineVerification
    case pendingDependencyVerification
    case missingDependency
    case conflictLoser
    
    case evictedInvalidAtom
    case evictedFailedConstraintMachineVerification
}

extension AtomStatusNotStored {
    init(atomStatus: AtomStatus) {
        
        switch atomStatus {
        case .stored: incorrectImplementation("Should have been handled in AtomStatusEvent.stored")
        case .conflictLoser: self = .conflictLoser
        case .doesNotExist: self = .doesNotExist
        case .missingDependency: self = .missingDependency
        case .pendingConstraintMachineVerification: self = .pendingConstraintMachineVerification
        case .pendingDependencyVerification: self = .pendingDependencyVerification
        case .evictedConflictLoser: self = .evictedConflictLoser
        case .evictedInvalidAtom: self = .evictedInvalidAtom //(error: error)
        case .evictedFailedConstraintMachineVerification: self = .evictedFailedConstraintMachineVerification // (error: error)
        }
    }
}
