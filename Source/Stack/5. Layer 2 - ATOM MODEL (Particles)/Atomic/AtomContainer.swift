//
//  AtomContainer.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-17.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol AtomContainer: Atomic, DSONEncodable, RadixHashable, SignableConvertible {
    associatedtype WrappedAtom: Atomic
    var wrappedAtom: WrappedAtom { get }
}

// MARK: - AtomContainer + DSONEncodable
public extension AtomContainer where Self: DSONEncodable, Self.WrappedAtom: DSONEncodable {
    func toDSON(output: DSONOutput) throws -> DSON {
        return try wrappedAtom.toDSON(output: output)
    }
}

// MARK: - AtomContainer + RadixHashable
public extension AtomContainer where Self: RadixHashable, Self.WrappedAtom: RadixHashable {
    var radixHash: RadixHash {
        return wrappedAtom.radixHash
    }
}

// MARK: - AtomContainer + SignableConvertible
public extension AtomContainer where Self: SignableConvertible, Self.WrappedAtom: SignableConvertible {
    var signable: Signable {
        return wrappedAtom as Signable
    }
}

// MARK: - AtomContainer + Atomic
public extension AtomContainer {
    var particleGroups: ParticleGroups { return wrappedAtom.particleGroups }
    var signatures: Signatures { return wrappedAtom.signatures }
    var metaData: ChronoMetaData { return wrappedAtom.metaData }
}
