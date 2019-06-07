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

class ProofOfWorkTest: XCTestCase {
    
    private let powWorker = DefaultProofOfWorkWorker()
    
    func testPowSingleLeadingZero() {
        let magic: Magic = 1
        let seed = Data(repeating: 0x00, count: 32)
        guard let pow = doPow(worker: powWorker, seed: seed.asData, magic: magic, numberOfLeadingZeros: 1) else { return XCTFail("timeout") }
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
        guard let pow = doPow(worker: powWorker, seed: seed.asData, magic: magic, numberOfLeadingZeros: 4, timeout: 1) else { return XCTFail("timeout") }
        do {
            try pow.prove()
            XCTAssertEqual(pow.nonceAsString, "30")
        } catch {
            XCTFail("POW fail, error: \(error)")
            
        }
    }
}

extension XCTestCase {
    
    func doPow(
        worker: DefaultProofOfWorkWorker,
        atom: Atom,
        magic: Magic,
        numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default,
        timeout: RxTimeInterval? = RxTimeInterval.enoughForPOW,
        _ function: String = #function, _ file: String = #file
        ) -> ProofOfWork? {
        return doPow(
            worker: worker,
            seed: atom.radixHash.asData,
            magic: magic,
            numberOfLeadingZeros: numberOfLeadingZeros,
            timeout: timeout, function, file
        )
    }
    
    func doPow(
        worker: DefaultProofOfWorkWorker,
        seed: Data,
        magic: Magic,
        numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default,
        timeout: RxTimeInterval? = nil,
        _ function: String = #function, _ file: String = #file
        ) -> ProofOfWork? {
        
        return worker.work(
            seed: seed,
            magic: magic,
            numberOfLeadingZeros: numberOfLeadingZeros
            )
            .blockingTakeFirst(
                timeout: timeout,
                failOnTimeout: true,
                failOnNil: true,
                function: function,
                file: file
        )
    }
}
