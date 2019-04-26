//
//  RadixIdentity+ExpressilbleByIntegerLiteral.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-26.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK

// MARK: - ExpressibleByIntegerLiteral
/* For testing only. Do NOT use Int64 to create a private key */
extension RadixIdentity: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        guard isDebug else {
            incorrectImplementation("Do NOT use an Int to initialize a private key, that is not secure!")
        }
        do {
            let privateKey = try PrivateKey(scalar: BigUnsignedInt(value))
            self.init(private: privateKey)
        } catch {
            incorrectImplementation("Bad value sent, error: \(error)")
        }
    }
}
