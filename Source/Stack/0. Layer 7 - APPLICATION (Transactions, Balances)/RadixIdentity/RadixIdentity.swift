//
//  RadixIdentity.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

///// A container of a cryptographic keypair and an address, used for higher level APIs.
//public struct RadixIdentity:
//    AtomSigning,
//    SignedAtomVerifier,
//    Signing,
//    Ownable,
//    PublicKeyOwner,
//    Sharded,
//    Equatable
//{
//    private let keyPair: KeyPair
//    public let address: Address
//    
//    public init(keyPair: KeyPair, address: Address) {
//        self.keyPair = keyPair
//        self.address = address
//    }
//}
////
//// MARK: - Convenience Init
//public extension RadixIdentity {
//    init(`private` privateKey: PrivateKey, magic: Magic) {
//        let keyPair = KeyPair(private: privateKey)
//        let address = Address(magic: magic, publicKey: keyPair.publicKey)
//        self.init(keyPair: keyPair, address: address)
//    }
//
//    init(magic: Magic) {
//        // Generate a new PrivateKey
//        let privateKey = PrivateKey()
//        self.init(private: privateKey, magic: magic)
//    }
//}
//
//// MARK: - PublicKeyOwner
//public extension RadixIdentity {
//    var publicKey: PublicKey {
//        return keyPair.publicKey
//    }
//}
//
//// MARK: - Equatable
//public extension RadixIdentity {
//    static func == (lhs: RadixIdentity, rhs: RadixIdentity) -> Bool {
//        return lhs.privateKey == rhs.privateKey
//    }
//}
//
//// MARK: - Signing
//public extension RadixIdentity {
//    var privateKey: PrivateKey {
//        return keyPair.privateKey
//    }
//}
//
//// MARK: - Signing
//public extension RadixIdentity {
//    var shard: Shard {
//        return publicKey.shard
//    }
//}
