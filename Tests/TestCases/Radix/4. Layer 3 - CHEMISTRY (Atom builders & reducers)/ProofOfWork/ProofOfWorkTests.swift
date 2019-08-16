//
// MIT License
// 
// Copyright (c) 2018-2019 Radix DLT ( https://radixdlt.com )
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
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
    
    // Takes around 7 second per vector
    func omitted_slowVectors() {
        func test(vector: Vector) {
            
            doTest(
                zeros: vector.zeros,
                expectedNonce: vector.expectedResultingNonce,
                magic: vector.magic,
                seed: vector.seed
            )
        }
        vectorsForHighNonce.forEach(test(vector:))
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
        
        DefaultProofOfWorkWorker().doWork(seed: seedUsed.asData, magic: magicUsed, numberOfLeadingZeros: zeros) {
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
        timeout: TimeInterval? = .enoughForPOW,
        _ function: String = #function, _ file: String = #file, _ line: Int = #line
        ) -> ProofOfWork? {
        return doPow(
            worker: worker,
            seed: atom.radixHash.asData,
            magic: magic,
            numberOfLeadingZeros: numberOfLeadingZeros,
            timeout: timeout, function, file, line
        )
    }
    
    func doPow(
        worker: DefaultProofOfWorkWorker,
        seed: Data,
        magic: Magic,
        numberOfLeadingZeros: ProofOfWork.NumberOfLeadingZeros = .default,
        timeout: TimeInterval? = nil,
        _ function: String = #function, _ file: String = #file, _ line: Int = #line
        ) -> ProofOfWork? {
        
        return worker.work(
            seed: seed,
            magic: magic,
            numberOfLeadingZeros: numberOfLeadingZeros
        ).blockingSingle(timeout: timeout, function: function, file: file, line: line)
    }
}

extension PrimitiveSequenceType where Self: ObservableConvertibleType, Trait == SingleTrait {
    func blockingSingle(
        timeout: TimeInterval? = .default,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Element? {
        let description = "\(function) in \(file), at line: \(line)"
        do {
            return try toBlocking(timeout: timeout).single()
        } catch RxError.timeout {
            if failOnTimeout {
                XCTFail("Timeout, \(description)")
            }
            return nil
        } catch RxError.moreThanOneElement {
            fatalError("RxError.moreThanOneElement, \(description)")
        } catch let rpcError as RPCError {
            fatalError("rpcError: \(rpcError)")
        } catch {
            XCTFail("Unexpected error thrown: \(error), \(description)")
            return nil
        }
        
    }
}

private typealias Vector = (zeros: ProofOfWork.NumberOfLeadingZeros, magic: Magic, seed: HexString, expectedResultingNonce: Nonce)
private let vectorsForHighNonce: [Vector] = [
    (
        zeros: 16,
        magic: -1332248574,
        seed: "46ad4f54098f18f856a2ff05df25f5af587bd4f6dfc1e3b4cb406ceb25c61552",
        expectedResultingNonce: 322571
    ),
    (
        zeros: 16,
        magic: -1332248574,
        seed: "a33a90d0422aa12b68d1de6c53e83ca049ab82b06efeb03cf6731231e82470ef",
        expectedResultingNonce: 311476
    ),
    (
        zeros: 16,
        magic: -1332248574,
        seed: "0519269eafbac3accba00cf6f7e93238aae1974a1e5439a58a6f53726a963095",
        expectedResultingNonce: 285315
    ),
    (
        zeros: 16,
        magic: -1332248574,
        seed: "34931f7c0522352426d9d95f1c5527fafffce55b13082ae3723dc89f3c3e6276",
        expectedResultingNonce: 270233
    )
]

