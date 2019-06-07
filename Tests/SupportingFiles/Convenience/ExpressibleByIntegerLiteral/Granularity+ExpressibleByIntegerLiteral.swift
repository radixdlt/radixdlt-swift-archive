//
//  Granularity+ExpressibleByIntegerLiteral.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-06-06.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK

// MARK: - ExpressibleByIntegerLiteral
extension Granularity: ExpressibleByIntegerLiteral {}
public extension Granularity {
    init(integerLiteral int: UInt) {
        do {
            try self.init(int: int)
        } catch {
            fatalError("Passed bad value, error: \(error), value: \(int)")
        }
    }
}

// MARK: - ExpressibleByIntegerLiteral
extension EUID: ExpressibleByIntegerLiteral {}
public extension EUID {
    init(integerLiteral int: Int) {
        do {
            try self.init(int: int)
        } catch {
            fatalError("Passed bad value, error: \(error), value: \(int)")
        }
    }
}
