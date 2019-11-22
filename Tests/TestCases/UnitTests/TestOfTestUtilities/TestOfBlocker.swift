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
import XCTest
import Combine

extension FixedWidthInteger {
    static func random() -> Self {
        Self.random(in: Self.min..<Self.max)
    }
}

extension TimeInterval {
    static var ms100: Self { 0.1 }
    static var ms50: Self { 0.05 }
}

final class TestOfBlocker: TestCase {
    
    func testOfUInt8PublisherOperatorFirst() {
        let intPublisher: AnyPublisher<UInt8, Never> = Timer.publish(every: .ms50, on: RunLoop.main, in: .common)
            .autoconnect()
            .map { _ in Swift.print("✅"); return UInt8.random() }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
        
        let blocker = Blocker.first(of: intPublisher)
        let result = blocker.blocking()
        let values = XCTAssertNotThrows(try result.get())
        XCTAssertEqual(values?.count, 1)
    }
    
    func testOfIntPublisherOutputFirst() throws {
        let intPublisher: AnyPublisher<Int, Never> = Timer.publish(every: .ms50, on: RunLoop.main, in: .common)
            .autoconnect()
            .map { _ in Swift.print("✅"); return Int(42) }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
        
        XCTAssertEqual(
            try intPublisher.blockingOutputFirst(),
            42
        )
    }
    
    func testOfIgnoringOutputPublisher() throws {
        let publisher = Timer.publish(every: .ms50, on: RunLoop.main, in: .common)
            .autoconnect()
            .receive(on: RunLoop.main)
            .first()
        
        
        let blocker = Blocker.ignoreOutput(of: publisher)
        let result = blocker.blocking()
        switch result {
        case .failure(let error): return XCTFail("Failed with error: \(error)")
        case .success: XCTAssert(true)
        }
    }
    
    func testOfIgnoringOutputPublisherShort() {
        let publisher = Timer.publish(every: .ms50, on: RunLoop.main, in: .common)
            .autoconnect()
            .receive(on: RunLoop.main)
            .first()
        
        XCTAssertTrue(publisher.blockingIgnoreOutputSuccess())
    }
    
    
    func testOfIgnoringOutputPublisherExpectedTimeout() {
        let publisher = Timer.publish(every: .ms50, on: RunLoop.main, in: .common)
            .autoconnect()
            .receive(on: RunLoop.main)
            .first()
     
        let notEnoughTime: DispatchTimeInterval = .milliseconds(40)
        let blockedResult = publisher.blockingIgnoreOutput(timeout: notEnoughTime)

        XCTAssertThrowsSpecificError(
            try blockedResult.get(),
            BlockerError<NoOutput, Never>.timedOut(after: notEnoughTime, outputUntilTimeout: [])
        )
        
    }
}
