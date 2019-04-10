//
//  ProofOfWork+NumberOfLeadingZeros.swift
//  RadixSDK iOS
//
//  Created by Alexander Cyon on 2019-04-10.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation

public extension ProofOfWork {
    struct NumberOfLeadingZeros: ExpressibleByIntegerLiteral {
        
        public let numberOfLeadingZeros: Value
        
        init(_ numberOfLeadingZeros: Value) throws {
            
            guard numberOfLeadingZeros >= NumberOfLeadingZeros.minimumNumberOfLeadingZeros else {
                throw Error.tooFewLeadingZeros(
                    expectedAtLeast: NumberOfLeadingZeros.minimumNumberOfLeadingZeros,
                    butGot: numberOfLeadingZeros
                )
            }
            
            self.numberOfLeadingZeros = numberOfLeadingZeros
        }
    }
}

// MARK: - Presets
public extension ProofOfWork.NumberOfLeadingZeros {
    static let minimumNumberOfLeadingZeros: Value = 1

    static let `default`: ProofOfWork.NumberOfLeadingZeros = 16
}

// MARK: - Errors
public extension ProofOfWork.NumberOfLeadingZeros {
    typealias Value = UInt8
    
    enum Error: Swift.Error {
        case tooFewLeadingZeros(expectedAtLeast: Value, butGot: Value)
    }
}

// MARK: - ExpressibleByIntegerLiteral
public extension ProofOfWork.NumberOfLeadingZeros {
    init(integerLiteral value: Value) {
        do {
            try self.init(value)
        } catch {
            fatalError("Bad value, error: \(error)")
        }
    }
}
