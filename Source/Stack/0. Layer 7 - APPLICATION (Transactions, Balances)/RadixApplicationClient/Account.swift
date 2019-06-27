//
//  Account.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-06-14.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
import RxSwift

public enum Account: Hashable, AtomSigning, SigningRequesting, PublicKeyOwner {
    case privateKeyPresent(KeyPair)
    case privateKeyNotPresent(PublicKey)
}

public extension Account {
    var publicKey: PublicKey {
        switch self {
        case .privateKeyPresent(let publicKeyOwner): return publicKeyOwner.publicKey
        case .privateKeyNotPresent(let publicKeyOwner): return publicKeyOwner.publicKey
        }
    }
    
    var privateKey: PrivateKey? {
        switch self {
        case .privateKeyPresent(let privateKeyOwner): return privateKeyOwner.privateKey
        case .privateKeyNotPresent: return nil
        }
    }
    
    var privateKeyForSigning: SingleWanted<PrivateKey> {
        if let privateKey = privateKey {
            return SingleWanted.just(privateKey)
        } else {
            return requestSignableKeyFromUser(matchingPublicKey: publicKey)
        }
    }
}

public extension Account {
    func addressFromMagic(_ magic: Magic) -> Address {
        return Address(magic: magic, publicKey: publicKey)
    }
}

public extension Account {
    func requestSignableKeyFromUser(matchingPublicKey: PublicKey) -> SingleWanted<PrivateKey> {
        implementMe()
    }
}
