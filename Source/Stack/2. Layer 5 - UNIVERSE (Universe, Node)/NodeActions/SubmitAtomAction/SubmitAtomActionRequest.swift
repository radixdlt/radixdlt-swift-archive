//
//  SubmitAtomActionRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-08-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct SubmitAtomActionRequest: SubmitAtomAction, FindANodeRequestAction {
    public let atom: SignedAtom
    public let isCompletingOnStoreOnly: Bool
    public let uuid: UUID
    
    public init(atom: SignedAtom, isCompletingOnStoreOnly: Bool, uuid: UUID = .init()) {
        self.atom = atom
        self.isCompletingOnStoreOnly = isCompletingOnStoreOnly
        self.uuid = uuid
    }
}
public extension SubmitAtomActionRequest {
    var shards: Shards {
        do {
            return try atom.requiredFirstShards()
        } catch { incorrectImplementation("should always be able to get shards") }
    }
}
