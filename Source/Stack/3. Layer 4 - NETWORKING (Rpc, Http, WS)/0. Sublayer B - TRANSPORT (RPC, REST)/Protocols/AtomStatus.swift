//
//  AtomStatus.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-28.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

/// The different states an atom can be in.
public enum AtomStatus: String, Equatable, Codable {
    case doesNotExist                                   = "DOES_NOT_EXIST"
    
    case evictedInvalidAtom                             = "EVICTED_INVALID_ATOM"
    case evictedFailedConstraintMachineVerification     = "EVICTED_FAILED_CM_VERIFICATION"
    case evictedConflictLoser                           = "EVICTED_CONFLICT_LOSER"
    case pendingConstraintMachineVerification           = "PENDING_CM_VERIFICATION"
    case pendingDependencyVerification                  = "PENDING_DEPENDENCY_VERIFICATION"
    case missingDependency                              = "MISSING_DEPENDENCY"
    case conflictLoser                                  = "CONFLICT_LOSER"
    
    case stored                                         = "STORED"
}
