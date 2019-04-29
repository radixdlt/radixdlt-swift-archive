//
//  ProofOfWorkTests.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-01.
//  Copyright © 2019 Radix DLT. All rights reserved.
//

import Foundation
@testable import RadixSDK
import XCTest
import RxSwift
import RxTest
import RxBlocking

extension ProofOfWork {
    
    static func work(
        atom: Atom,
        magic: Magic,
        numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default,
        timeout: RxTimeInterval? = nil,
        _ function: String = #function, _ file: String = #file
        ) -> ProofOfWork? {
        return work(
            seed: atom.radixHash.asData,
            magic: magic,
            numberOfLeadingZeros: numberOfLeadingZeros,
            timeout: timeout, function, file
        )
    }
    
    static func work(
        seed: Data,
        magic: Magic,
        numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default,
        timeout: RxTimeInterval? = nil,
        _ function: String = #function, _ file: String = #file
        ) -> ProofOfWork? {
        let observable = ProofOfWorkWorker().work(seed: seed, magic: magic, numberOfLeadingZeros: numberOfLeadingZeros)
        return observable.blockingTakeFirst(timeout: timeout, failOnTimeout: true, failOnNil: true, function: function, file: file)
    }
}

class ProofOfWorkTest: XCTestCase {
    
    func testPowSingleLeadingZero() {
        let magic: Magic = 1
        let seed = Data(repeating: 0x00, count: 32)
        guard let pow = ProofOfWork.work(seed: seed.asData, magic: magic, numberOfLeadingZeros: 1) else { return XCTFail("timeout") }
        do {
            try pow.prove()
            XCTAssertEqual(pow.nonceAsString, "5")
        } catch {
            XCTFail("POW fail, error: \(error)")
            
        }
    }
    
    func test4LeadingZerosDeadbeefSeed() {
        let magic: Magic = 12345
        let seed: HexString = "deadbeef00000000deadbeef00000000deadbeef00000000deadbeef00000000"
        guard let pow = ProofOfWork.work(seed: seed.asData, magic: magic, numberOfLeadingZeros: 4) else { return XCTFail("timeout") }
        do {
            try pow.prove()
            XCTAssertEqual(pow.nonceAsString, "30")
        } catch {
            XCTFail("POW fail, error: \(error)")
            
        }
    }
}
