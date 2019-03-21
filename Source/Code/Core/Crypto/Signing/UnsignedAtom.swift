//
//  UnsignedAtom.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public struct UnsignedAtom: Signable {
    
    public enum Error: Swift.Error {
        case atomAlreadySigned
    }
    
    public let unsignedAtom: Atom
    
    public init(_ unsignedAtom: Atom) throws {
        guard unsignedAtom.signatures.isEmpty else {
            throw Error.atomAlreadySigned
        }
        self.unsignedAtom = unsignedAtom
    }
}

public extension UnsignedAtom {
    var signableData: Data {
        return unsignedAtom.signableData
    }
}

public extension UnsignedAtom {
    func signed(signature: Signature, signatureId: EUID) -> SignedAtom {
        return unsignedAtom.withSignature(signature, signatureId: signatureId)
    }
}
