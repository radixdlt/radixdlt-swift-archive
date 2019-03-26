//
//  NodeAtomSubmissionUpdate.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct NodeAtomSubmissionUpdate {
    public let state: State
    public let data: Data
    public let timestamp: Date
}

public extension NodeAtomSubmissionUpdate {
    public enum State: Int, Equatable {
        var isCompletable: Bool {
            switch self {
            case .received: return false
            case .failed, .stored, .collision, .illegal, .unsuitablePeer, .validationError, .unknownError:
                return true
            }
        }
        case received
        case failed
        case stored
        case collision
        case illegal
        case unsuitablePeer
        case validationError
        case unknownError
    }
}

public struct SubmitAtomResultAction: SubmitAtomAction {
    public let node: Node
    public let atom: Atom
    public let uuid: UUID
    public let result: Result
    public let data: Data?
    
    public init(node: Node, atom: Atom, uuid: UUID, result: Result, data: Data?) {
        self.node = node
        self.atom = atom
        self.uuid = uuid
        self.result = result
        self.data = data
    }
    
    public static func fromUpdate(node: Node, atom: Atom, uuid: UUID, update: NodeAtomSubmissionUpdate) -> SubmitAtomResultAction {
        let result = SubmitAtomResultAction.Result(nodeAtomSubmissionUpdate: update.state)
        let data = update.data
        return SubmitAtomResultAction(node: node, atom: atom, uuid: uuid, result: result, data: data)
    }
}

public extension SubmitAtomResultAction {
    public enum Result: Int, Equatable {
        case failed
        case stored
        case collision
        case illegal
        case unsuitablePeer
        case validationError
        case unknownError
        
        init(nodeAtomSubmissionUpdate: NodeAtomSubmissionUpdate.State) {
            switch nodeAtomSubmissionUpdate {
            case .failed: self = .failed
            case .stored: self = .stored
            case .collision: self = .collision
            case .illegal: self = .illegal
            case .unsuitablePeer: self = .unsuitablePeer
            case .validationError: self = .validationError
            case .unknownError: self = .unknownError
            case .received: incorrectImplementation("Not supported")
            }
        }
    }
}

public struct SubmitAtomReceivedAction: SubmitAtomAction {
    public let node: Node
    public let atom: Atom
    public let uuid: UUID
}
