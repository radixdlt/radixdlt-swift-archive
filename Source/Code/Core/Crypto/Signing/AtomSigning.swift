//
//  AtomSigning.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-03-20.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol AtomSigning {
    func sign(atom unsignedAtom: UnsignedAtom) throws -> SignedAtom
}
