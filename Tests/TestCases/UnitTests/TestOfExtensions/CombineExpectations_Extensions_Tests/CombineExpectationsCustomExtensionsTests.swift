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

import XCTest
import Combine
@testable import RadixSDK

final class CombineExpectationsCustomExtensionsTests: TestCase {

    func testError() throws {
        let publisher = Fail<Int, TestError>(error: .foo)
        let recorder = publisher.record()
        let testError: TestError = try wait(for: recorder.expectError(), timeout: 0.1)
        XCTAssertEqual(testError, .foo)
    }

    func testNoError() {
        let publisher = Empty<Int, TestError>(completeImmediately: true)
        let recorder = publisher.record()
        do {
            _ = try wait(for: recorder.expectError(ofType: TestError.self), timeout: 0.1)
        } catch let recordingError as RecordingError {
            switch recordingError {
            case .expectedPublisherToFailButGotFinish(let expectedErrorType):
                XCTAssertType(of: expectedErrorType, is: TestError.Type.self)
            default:
                XCTFail("Got unexpected recordingError: \(recordingError), should have been error case: `expectedPublisherToFailButGotFinish`")
            }
        } catch {
            XCTFail("Got unexpected error: \(error), but expected RecordingError.expectedPublisherToFailButGotFinish")
        }
    }
    
    func testErrorDifferentTypeThanPublisher() {
        let publisher = Fail<Int, OtherError>(error: .biz)
        let recorder = publisher.record()
        do {
            _ = try wait(for: recorder.expectError(ofType: TestError.self), timeout: 0.1)
        } catch let recordingError as RecordingError {
            switch recordingError {
            case .failedToMapErrorFromFailureToExpectedErrorType(let expectedErrorType, let butGotFailure):
                XCTAssertType(of: expectedErrorType, is: TestError.Type.self)
                let wrongErrorType: OtherError! = XCTAssertType(of: butGotFailure)
                XCTAssertEqual(wrongErrorType, .biz)
            default:
                XCTFail("Got unexpected recordingError: \(recordingError), should have been error case: `expectedPublisherToFailButGotFinish`")
            }
        } catch {
            XCTFail("Got unexpected error: \(error), but expected RecordingError.expectedPublisherToFailButGotFinish")
        }
    }
    
    func testNoErrorDifferentTypeThanPublisher() {
        let publisher = Empty<Int, OtherError>(completeImmediately: true)
        let recorder = publisher.record()
        do {
            _ = try wait(for: recorder.expectError(ofType: TestError.self), timeout: 0.1)
        } catch let recordingError as RecordingError {
            switch recordingError {
            case .expectedPublisherToFailButGotFinish(let expectedErrorType):
                XCTAssertType(of: expectedErrorType, is: TestError.Type.self)
            default:
                XCTFail("Got unexpected recordingError: \(recordingError), should have been error case: `expectedPublisherToFailButGotFinish`")
            }
        } catch {
            XCTFail("Got unexpected error: \(error), but expected RecordingError.expectedPublisherToFailButGotFinish")
        }
    }
    
    func testNestedError() throws {
        let alice: Address = .irrelevant
        let putUniqueIdAction = PutUniqueIdAction(uniqueMaker: alice, string: "foo")
        let putUniqueIdError = PutUniqueIdError.uniqueError(.rriAlreadyUsedByUniqueId(string: "foo"))
        
        let transactionError = TransactionError.actionsToAtomError(
            .putUniqueIdError(putUniqueIdError, action: putUniqueIdAction)
        )
        
        let publisher = Fail<Int, TransactionError>(
            error: transactionError
        )
        
        let recorder = publisher.record()
        let recordedError: TransactionError = try wait(for: recorder.expectError(), timeout: 0.1)
        XCTAssertEqual(transactionError, recordedError)
    }
}

private extension CombineExpectationsCustomExtensionsTests {
    enum TestError: Int, Error, Equatable {
        case foo, bar
    }
    enum OtherError: Int, Error, Equatable {
        case biz
    }
}
