//
//  AtomStatusEvent.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-28.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public enum AtomStatusEvent: Decodable, Equatable, CustomStringConvertible, CustomDebugStringConvertible {
    case stored
    case notStored(reason: AtomNotStoredReason)
}

// MARK: CustomStringConvertible
public extension AtomStatusEvent {
    var debugDescription: String {
        switch self {
        case .stored: return "Stored"
        case .notStored(let reason): return "NotStored(reason: \(reason))"
        }
    }
    
    var description: String {
        switch self {
        case .stored: return "Stored"
        case .notStored: return "NotStored"
        }
    }
}

// MARK: Decodable
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

