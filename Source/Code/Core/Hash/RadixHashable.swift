//
//  RadixHashable.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-01-22.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public protocol RadixHashable: DSONEncodable {
    var radixHash: RadixHash { get }
    var hashId: EUID { get }
}

public extension RadixHashable {
    var radixHash: RadixHash {
        do {
            return RadixHash(unhashedData: try toDSON(output: .hash))
        } catch {
            incorrectImplementation("Should always be able to hash, error: \(error)")
        }
    }
    
    var hashId: EUID {
        return radixHash.toEUID()
    }
}

// MARK: - Hashable Prepare
public extension RadixHashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(radixHash)
    }
}
