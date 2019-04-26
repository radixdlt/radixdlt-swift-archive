//
//  EUIDTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-03-19.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

@testable import RadixSDK
import Nimble
import Quick

class EUIDSpec: QuickSpec {
    
    override func spec() {
        describe("EUID") {
            describe("verification of values") {
                it("should be possible to instantiate with Data of length 16") {
                    expect { try EUID(Data( [Byte](repeating: 0x01, count: 16))) }.toNot(throwError())
                }
                it("should not be possible to instantiate with too short Data") {
                    expect { try EUID(Data( [Byte](repeating: 0x01, count: 15))) }
                        .to(throwError(InvalidStringError.tooFewCharacters(expectedAtLeast: 16, butGot: 15)))
                }
                it("should not be possible to instantiate with too long Data") {
                    expect { try EUID(Data( [Byte](repeating: 0x01, count: 17))) }
                        .to(throwError(InvalidStringError.tooManyCharacters(expectedAtMost: 16, butGot: 17)))
                }
            }
        }
    }
}
