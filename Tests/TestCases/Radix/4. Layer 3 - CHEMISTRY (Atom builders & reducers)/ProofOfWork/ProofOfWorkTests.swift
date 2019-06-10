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
    
    private let magic: Magic = 12345
    private let seed: HexString = "deadbeef00000000deadbeef00000000deadbeef00000000deadbeef00000000"
    
    func test1LeadingZero() {
        doTest(zeros: 1, expectedNonce: 2)
    }
    
    func test4LeadingZeros() {
        doTest(zeros: 4, expectedNonce: 30)
    }
    
    func test10LeadingZeros() {
        measure { // strictly less than 0.01 sec without optimization
            doTest(zeros: 10, expectedNonce: 198)
        }
    }
    
    func test12LeadingZeros() {
        doTest(zeros: 12, expectedNonce: 6825)
    }
    
    func test14LeadingZeros() {
        doTest(zeros: 14, expectedNonce: 9255)
    }
    
    func test14LeadingZeroRx() {
        let powWorker = DefaultProofOfWorkWorker()
        guard let pow = doPow(worker: powWorker, seed: seed.asData, magic: magic, numberOfLeadingZeros: 14, timeout: 0.5) else { return XCTFail("timeout") }
        XCTAssertEqual(pow.nonce, 9255)
    }
}

private extension ProofOfWorkTest {
    func doTest(
        zeros: ProofOfWork.NumberOfLeadingZeros,
        expectedNonce: Nonce,
        magic overridingMagic: Magic? = nil,
        seed overridingSeed: HexString? = nil
    ) {
    
        let magicUsed = overridingMagic ?? magic
        let seedUsed = overridingSeed ?? seed
        
        DefaultProofOfWorkWorker.work(seed: seedUsed.asData, magic: magicUsed, numberOfLeadingZeros: zeros) {
            switch $0 {
            case .failure(let error): XCTFail("Unexpected error: \(error)")
            case .success(let pow): XCTAssertEqual(pow.nonce, expectedNonce)
            }
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
