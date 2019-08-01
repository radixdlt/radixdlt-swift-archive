//
//  RadixHashable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public typealias HashEUID = EUID

public protocol RadixHashable {
    var radixHash: RadixHash { get }
    var hashEUID: HashEUID { get }
}

public extension RadixHashable {
    var hashEUID: HashEUID {
        return radixHash.toEUID()
    }
}

public extension RadixHashable where Self: DSONEncodable {
    var radixHash: RadixHash {
        do {
            return RadixHash(unhashedData: try toDSON(output: .hash))
        } catch {
            incorrectImplementation("Should always be able to hash, error: \(error)")
        }
    }
}

// MARK: - Hashable Prepare
public extension RadixHashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(radixHash)
    }
}
