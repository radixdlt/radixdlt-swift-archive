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
import RxSwift
import RxTest
import RxBlocking
@testable import RadixSDK

extension Observable where Element == Void {
    
    func blockingWasSuccessfull(
        _ takeCount: Int = 1,
        timeout: TimeInterval? = .default,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
        ) -> Bool {
        
        guard let _ = blockingTakeFirst(
            takeCount,
            timeout: timeout,
            failOnTimeout: failOnTimeout,
            failOnNil: failOnNil,
            function: function,
            file: file,
            line: line
            ) else {
                return false
        }
        return true
    }
}

extension ObservableConvertibleType where Element == Never { /* Completable */
    
    func blockingWasSuccessfull(
        timeout: TimeInterval? = .default,
        failOnTimeout: Bool = true,
        failOnErrors: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
        ) -> Bool {
        
        let description = "\(function) in \(file), at line: \(line)"
        switch self.toBlocking(timeout: timeout).materialize() {
        case .completed: return true
        case .failed(_, let error):
            if let rxError = error as? RxError {
                if case .timeout = rxError {
                    if failOnTimeout {
                        XCTFail("Timeout after \(timeout!)s, \(description)")
                    }
                }
            } else {
                if failOnErrors {
                    XCTFail("Error: \(error) - \(description)")
                }
            }
            return false
        }
    }
    
    func blockingAssertThrows<SpecificError>(
        error expectedError: SpecificError,
        timeout: TimeInterval? = .default,
        errorMapper: ((Swift.Error) -> SpecificError?)? = nil
    ) where SpecificError: Swift.Error, SpecificError: Equatable {
        
        self.toBlocking(timeout: timeout)
            .expectToThrow(
                error: expectedError,
                errorMapper: errorMapper
            )
        
    }
}

extension TimeInterval {
    static var `default`: TimeInterval {
        return 2
    }
    static var enoughForPOW: TimeInterval {
        return 15
    }
}

extension Observable {
    
    func blockingAssertThrows<SpecificError>(
        error expectedError: SpecificError,
        timeout: TimeInterval? = .default,
        errorMapper: ((Swift.Error) -> SpecificError?)? = nil
    ) where SpecificError: Swift.Error, SpecificError: Equatable {
        
        toBlocking(timeout: timeout)
            .expectToThrow(
                error: expectedError,
                errorMapper: errorMapper
            )
    }
    
    func blockingTakeFirst(
        _ takeCount: Int = 1,
        timeout: TimeInterval? = .default,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
        ) -> Element? {
        
        return blockingTake(
            takeCount,
            at: .first,
            timeout: timeout,
            failOnTimeout: failOnTimeout,
            failOnNil: failOnNil,
            function: function,
            file: file,
            line: line
        )
    }
    
    func blockingTakeLast(
        _ takeCount: Int = 1,
        timeout: TimeInterval? = .default,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
        ) -> Element? {
        
        return blockingTake(
            takeCount,
            at: .last,
            timeout: timeout,
            failOnTimeout: failOnTimeout,
            failOnNil: failOnNil,
            function: function,
            file: file,
            line: line
        )
    }
    
    func blockingTake(
        _ takeCount: Int = 1,
        at takeElementAt: ElementAt,
        timeout: TimeInterval? = .default,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
        ) -> Element? {

        return take(takeCount)
            .toBlocking(timeout: timeout)
            .getElement(
                at: takeElementAt,
                failOnTimeout: failOnTimeout,
                failOnNil: failOnNil,
                function: function,
                file: file,
                line: line
        )
    }
    
    func blockingArrayTakeFirst(
        _ takeCount: Int = 1,
        timeout: TimeInterval? = .default,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> [Element]? {
        
        return take(takeCount)
            .toBlocking(timeout: timeout)
            .getArray(
                timeout: timeout,
                failOnTimeout: failOnTimeout,
                failOnNil: failOnNil,
                function: function,
                file: file,
                line: line
            )
        
    }
}

enum ElementAt {
    case first
    case last
}

extension BlockingObservable {
    func getElement(
        at getElementAt: ElementAt = .first,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> Element? {
        let description = "\(function) in \(file), at line: \(line)"
        do {
            let element: Element?
            switch getElementAt {
            case .first:
                element = try self.first()
            case .last:
                element = try self.last()
            }
            if failOnNil {
                XCTAssertNotNil(element, "Element should not be nil, \(description)")
            }
            return element
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
    
    func expectToThrow<SpecificError>(
        error expectedError: SpecificError,
        errorMapper: ((Swift.Error) -> SpecificError?)? = nil
    )
        where
        SpecificError: Swift.Error,
        SpecificError: Equatable
    {
        switch materialize() {
        case .completed: return XCTFail("Expected error, but got `completed` instead")
        case .failed(_, let anyError):
            
            let mapToSpecificError = errorMapper ?? { $0 as? SpecificError }
            
            guard let mappedError = mapToSpecificError(anyError) else {
                return XCTFail("Got error as expected, but it has the wrong type, got error:\n<\(anyError)>\n, but expected error:\n<\(expectedError)>\n")
            }
            XCTAssertEqual(mappedError, expectedError)
        }
    }
    
    func getArray(
        timeout: TimeInterval? = .default,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
        ) -> [Element]? {
        let description = "\(function) in \(file), at line: \(line)"
        do {
            let array = try self.toArray()
            if failOnNil {
                XCTAssertNotNil(array, "Element should not be nil, \(description)")
            }
            return array
        } catch RxError.timeout {
            if failOnTimeout {
                XCTFail("Timeout, \(description)")
            }
            return nil
        } catch {
            fatalError("Unexpected error thrown: \(error), \(description)")
        }
    }
}


extension MaterializedSequenceResult {
    var wasSuccessful: Bool {
        switch self {
        case .completed: return true
        case .failed: return false
        }
    }
    
    func assertThrows<Error>(error expectedError: Error) -> Bool where Error: Swift.Error & Equatable {
        guard let mappedError = mapToError(type: Error.self) else {
            return false
        }
        return mappedError == expectedError
    }
    
    func mapToError<Error>(type expectedErrorType: Error.Type) -> Error? where Error: Swift.Error & Equatable {
        switch self {
        case .completed: return nil
        case .failed(_, let anyThrowedError): return anyThrowedError as? Error
        }
    }
}
