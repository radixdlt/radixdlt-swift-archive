//
//  MessageSending.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-05-31.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

//public protocol MessageSending {
//    /// Sends a message
//    func sendMessage(_ message: SendMessageAction) -> CompletableWanted
//}

//
//public extension DefaultRadixApplicationClient {
//    
//    private func doSendMessage(_ message: SendMessageAction, cc thirdPartyReaders: [Ownable] = []) -> CompletableWanted {
//        let actionToParticleGroupsMapper = DefaultSendMessageActionToParticleGroupsMapper(
//            readers: { ([$0.sender, $0.recipient] + thirdPartyReaders.map { $0.address }).map { $0.publicKey } }
//        )
//        let atom = actionToParticleGroupsMapper.particleGroups(for: message).wrapInAtom()
////        return performProvableWorkThenSignAndSubmit(atom: atom, powWorker: proofOfWorkWorker)
//        implementMe()
//    }
//}
//
//// swiftlint:disable opening_brace
//
//public extension MessageSending
//    where
//    Self: NodeInteractingSubmit,
//    Self: AtomSigning,
//    Self: Magical,
//    Self: IdentityHolder,
//    Self: ProofOfWorkWorking
//{
//    
//    // swiftlint:enable opening_brace
//    
//    func sendMessage(
//        data: Data,
//        to recipient: Ownable,
//        encryption mode: MessageEncryptionMode = .encrypted
//    ) -> CompletableWanted {
//        
//        var shouldBeEncrypted = false
//        var thirdPartyReaders = [Ownable]()
//        
//        if case let .encrypt(ccReaders) = mode {
//            shouldBeEncrypted = true
//            thirdPartyReaders = ccReaders
//        }
//        
//        let sendMessageAction = SendMessageAction(
//            from: self.identity,
//            to: recipient,
//            payload: data,
//            shouldBeEncrypted: shouldBeEncrypted
//        )
//        
//        return doSendMessage(sendMessageAction, cc: thirdPartyReaders)
//    }
//    
//    func sendMessage(
//        _ string: String,
//        encoding: String.Encoding = .default,
//        to recipient: Ownable,
//        encryption mode: MessageEncryptionMode = .encrypted
//    ) -> CompletableWanted {
//        
//        return sendMessage(
//            data: string.toData(encodingForced: encoding),
//            to: recipient,
//            encryption: mode
//        )
//    }
//}
