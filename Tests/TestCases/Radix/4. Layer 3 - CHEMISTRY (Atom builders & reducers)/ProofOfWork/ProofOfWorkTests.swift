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
    
//    func test16LeadingZeros() {
//        doTest(zeros: 16, expectedNonce: 241709)
//    }
    
//    func test20LeadingZeros() {
//        doTest(zeros: 20, expectedNonce: 1177532)
//    }
    
    func test16LeadingZeroRx() {
        let powWorker = DefaultProofOfWorkWorker()
        guard let pow = doPow(worker: powWorker, seed: seed.asData, magic: magic, numberOfLeadingZeros: 16, timeout: RxTimeInterval.enoughForPOW) else { return XCTFail("timeout") }
        XCTAssertEqual(pow.nonce, 241709)
    }
    
    func testCountNumberOfLeadingZeroBitsInData() {
        func doTest(data: DataConvertible, expectZeroCount: Int) {
            XCTAssertEqual(data.numberOfLeadingZeroBits, expectZeroCount)
        }
        doTest(data: Data(), expectZeroCount: 0)
        doTest(data: [0], expectZeroCount: 8)
        doTest(data: [1], expectZeroCount: 7)
        doTest(data: [255], expectZeroCount: 0)
        doTest(data: [0, 0], expectZeroCount: 16)
        doTest(data: [1, 0], expectZeroCount: 7)
        doTest(data: [0, 0, 0], expectZeroCount: 24)
        doTest(data: [1, 0, 0], expectZeroCount: 7)
        doTest(data: [255, 0, 0], expectZeroCount: 0)
        doTest(data: [0, 1, 0], expectZeroCount: 15)
        doTest(data: [0, 255, 0], expectZeroCount: 8)
        doTest(data: [0, 0, 0, 0], expectZeroCount: 32)
        doTest(data: [0, 0, 1, 0], expectZeroCount: 23)
        doTest(data: [0, 0, 0, 1], expectZeroCount: 31)
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
