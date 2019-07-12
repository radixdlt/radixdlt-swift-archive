//
//  AtomStatusEvent.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-28.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum AtomStatusEvent: Decodable, Equatable {
    case stored
    case notStored(reason: AtomNotStoredReason)
}

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

public struct AtomNotStoredReason: Equatable {
    let reason: AtomStatusNotStored
    //        let dataAsJsonString: String?
    let error: SubmitAtomError
    
    init(_ reason: AtomStatusNotStored, error: SubmitAtomError) {
        self.reason = reason
        self.error = error
    }
    
    init(atomStatus: AtomStatus, dataAsJsonString: String) {
        self.init(
            AtomStatusNotStored(atomStatus: atomStatus),
            error: SubmitAtomError(rpcError: RPCError.unrecognizedJson(jsonString: dataAsJsonString))
        )
    }
}

public extension AtomStatusEvent {
    enum CodingKeys: String, CodingKey {
        case atomStatus = "status"
        case dataAsJsonString = "data"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let atomStatus = try container.decode(AtomStatus.self, forKey: .atomStatus)

        switch atomStatus {
        case .stored:
            self = .stored
        default:
            
            let anyDecodable = try container.decode(AnyDecodable.self, forKey: .dataAsJsonString)
            let dataAsJsonString = String(describing: anyDecodable.value)
            
            let reasonForNotStored = AtomNotStoredReason(atomStatus: atomStatus, dataAsJsonString: dataAsJsonString)
            self = .notStored(reason: reasonForNotStored)
        }
        
    }
}

extension AtomStatusNotStored {
    init(atomStatus: AtomStatus) {
        
        switch atomStatus {
        case .stored: incorrectImplementation("Should have beeb handled in AtomStatusEvent.stored")
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

//public struct AtomStatusEvent: Decodable {
//    public let atomStatus: AtomStatus
//    //    public let dataAsJsonString: String
//}
//public extension AtomStatusEvent {
//    enum CodingKeys: String, CodingKey {
//        case atomStatus = "status"
//        //        case dataAsJsonString = "data"
//    }
//
//    init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//
//        atomStatus = try container.decode(AtomStatus.self, forKey: .atomStatus)
//
//        //        let anyDecodable = try container.decode(AnyDecodable.self, forKey: .dataAsJsonString)
//        //        dataAsJsonString = String(describing: anyDecodable.value)
//    }
//}
