//
//  MessageSending.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol MessageSending {
    /// Sends a message
    func sendMessage(_ message: SendMessageAction) -> CompletableWanted
}

// swiftlint:disable opening_brace

public extension MessageSending
    where
    Self: NodeInteractingSubmit,
    Self: AtomSigning,
    Self: Magical
{
    // swiftlint:enable opening_brace
    
    func sendMessage(_ message: SendMessageAction) -> CompletableWanted {
        return sendMessage(message, readers: [ /* No extra reader */ ])
    }
    
    func sendMessage(_ message: SendMessageAction, readers: [Ownable]) -> CompletableWanted {
        
        log.info("\(message.sender) send message to: \(message.recipient)")
        
        let actionToParticleGroupsMapper = DefaultSendMessageActionToParticleGroupsMapper()
        let atom = actionToParticleGroupsMapper.particleGroups(for: message).wrapInAtom()
        let powWorker = ProofOfWorkWorker()
        return performProvableWorkThenSignAndSubmit(atom: atom, powWorker: powWorker)
    }
}

// swiftlint:disable opening_brace

public extension MessageSending
    where
    Self: NodeInteractingSubmit,
    Self: AtomSigning,
    Self: Magical,
    Self: IdentityHolder
{
    
    // swiftlint:enable opening_brace
    
    func sendMessage(
        data: Data,
        to recipient: Ownable,
        encrypt shouldBeEncrypted: Bool = true,
        thirdPartyReaders readers: [Ownable] = []
    ) -> CompletableWanted {
        
        let sendMessageAction = SendMessageAction(
            from: self.identity,
            to: recipient,
            payload: data,
            shouldBeEncrypted: shouldBeEncrypted
        )
        
        return sendMessage(sendMessageAction, readers: readers)
    }
    
    func sendMessage(
        _ string: String,
        encoding: String.Encoding = .default,
        to recipient: Ownable,
        encrypt shouldBeEncrypted: Bool = true,
        thirdPartyReaders readers: [Ownable] = []
    ) -> CompletableWanted {
        
        return sendMessage(
            data: string.toData(encodingForced: encoding),
            to: recipient,
            encrypt: shouldBeEncrypted,
            thirdPartyReaders: readers
        )
    }
}
