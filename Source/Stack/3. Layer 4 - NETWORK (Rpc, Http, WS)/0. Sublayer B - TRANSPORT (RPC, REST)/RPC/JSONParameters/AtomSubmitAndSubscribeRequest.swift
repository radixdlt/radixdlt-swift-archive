//
//  AtomSubmitAndSubscribeRequest.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-30.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct AtomSubmitAndSubscribeRequest: Encodable {
    
    public let subscriberId: SubscriberId
    public let atom: Atom
    
    public init(atom signedAtom: SignedAtom, subscriberId: SubscriberId) {
        // TODO: Make `Atomic` conform to `Encodable`
        self.atom = Atom(atomic: signedAtom)
        self.subscriberId = subscriberId
    }
}
