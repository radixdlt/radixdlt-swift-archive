//
//  AtomStatusChecking.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-25.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public protocol AtomStatusChecking {
    func statusOfAtom(withIdentifier atomIdentifier: AtomIdentifier) -> SingleWanted<AtomStatus>
}

public protocol AtomStatusObserving {
    func observeAtomStatusNotifications(atomIdentifier: AtomIdentifier, subscriberId: SubscriberId) -> Observable<AtomStatusNotification>
}

/// The different states an atom can be in.
public enum AtomStatus: String, Equatable, Codable {
    case doesNotExist                                   = "DOES_NOT_EXIST"
    
    case evicted                                        = "EVICTED_INVALID_ATOM"
    case evictedFailedConstraintMachineVerification     = "EVICTED_FAILED_CM_VERIFICATION"
    case evictedConflictLoser                           = "EVICTED_CONFLICT_LOSER"
    case pendingConstraintMachineVerification           = "PENDING_CM_VERIFICATION"
    case pendingDependencyVerification                  = "PENDING_DEPENDENCY_VERIFICATION"
    case missingDependency                              = "MISSING_DEPENDENCY"
    case conflictLoser                                  = "CONFLICT_LOSER"
    
    case stored                                         = "STORED"
}

public struct AtomStatusNotification: Decodable {
    public let atomStatus: AtomStatus
    public let dataAsJsonString: String
}

public extension AtomStatusNotification {
    enum CodingKeys: String, CodingKey {
        case atomStatus = "status"
        case dataAsJsonString = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        atomStatus = try container.decode(AtomStatus.self, forKey: .atomStatus)
        
        let anyDecodable = try container.decode(AnyDecodable.self, forKey: .dataAsJsonString)
        dataAsJsonString = String(describing: anyDecodable.value)
    }
}
