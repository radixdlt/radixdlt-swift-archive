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
        return doSendMessage(message)
    }
}

// swiftlint:disable opening_brace
private extension MessageSending
    where
    Self: NodeInteractingSubmit,
    Self: AtomSigning,
    Self: Magical
{
    // swiftlint:enable opening_brace
    func doSendMessage(_ message: SendMessageAction, cc thirdPartyReaders: [Ownable] = []) -> CompletableWanted {
        let actionToParticleGroupsMapper = DefaultSendMessageActionToParticleGroupsMapper(
            readers: { ([$0.sender, $0.recipient] + thirdPartyReaders.map { $0.address }).map { $0.publicKey } }
        )
        let atom = actionToParticleGroupsMapper.particleGroups(for: message).wrapInAtom()
        let powWorker = ProofOfWorkWorker()
        return performProvableWorkThenSignAndSubmit(atom: atom, powWorker: powWorker)
    }
}

public enum MessageMode {
    // swiftlint:disable:next identifier_name
    case encrypt(cc: [Ownable])
    case plainText
}

public extension MessageMode {
    static var encrypted: MessageMode {
        return .encrypt(cc: [])
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
        encryption mode: MessageMode = .encrypted
    ) -> CompletableWanted {
        
        var shouldBeEncrypted = false
        var thirdPartyReaders = [Ownable]()
        
        if case let .encrypt(ccReaders) = mode {
            shouldBeEncrypted = true
            thirdPartyReaders = ccReaders
        }
        
        let sendMessageAction = SendMessageAction(
            from: self.identity,
            to: recipient,
            payload: data,
            shouldBeEncrypted: shouldBeEncrypted
        )
        
        return doSendMessage(sendMessageAction, cc: thirdPartyReaders)
    }
    
    func sendMessage(
        _ string: String,
        encoding: String.Encoding = .default,
        to recipient: Ownable,
        encryption mode: MessageMode = .encrypted
    ) -> CompletableWanted {
        
        return sendMessage(
            data: string.toData(encodingForced: encoding),
            to: recipient,
            encryption: mode
        )
    }
}
