//
//  PrivateKey+ExpressilbleByIntegerLiteral.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-11.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK

// MARK: - ExpressibleByIntegerLiteral
/* For testing only. Do NOT use Int64 to create a private key */
extension PrivateKey: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int) {
        guard isDebug else {
            incorrectImplementation("Do NOT use an Int to initialize a private key, that is not secure!")
        }
        do {
            try self.init(scalar: BigUnsignedInt(value))
        } catch {
            incorrectImplementation("Bad value sent, error: \(error)")
        }
    }
}
