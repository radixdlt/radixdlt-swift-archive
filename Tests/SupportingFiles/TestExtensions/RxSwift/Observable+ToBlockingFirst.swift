//
//  Observable+ToBlockingFirst.swift
//  RadixSDK iOS Tests
//
//  Created by Alexander Cyon on 2019-04-16.
//  Copyright © 2019 Radix DLT. All rights reserved.
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
                        XCTFail("Timeout, \(description)")
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
        timeout: TimeInterval? = .default
    ) where SpecificError: Swift.Error, SpecificError: Equatable {
        self.toBlocking(timeout: timeout).expectToThrow(error: expectedError)
    }
    
    func blockingAssertThrowsRPCErrorUnrecognizedJson<SpecificError>(
        timeout: TimeInterval? = .default,
        expectedErrorType: SpecificError.Type,
        containingString expectedSubStringInUnrecognizedStringError: String,
        function: String = #function,
        file: String = #file,
        line: Int = #line,
        deriveUnreconizedJsonError: @escaping (SpecificError) -> String?
    ) where SpecificError: Swift.Error {
        
        self.toBlocking(timeout: timeout).expectToThrowRPCErrorUnrecognizedJson(
            expectedErrorType: expectedErrorType,
            containingString: expectedSubStringInUnrecognizedStringError,
            function: function, file: file, line: line,
            deriveUnreconizedJsonError: deriveUnreconizedJsonError
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
        timeout: TimeInterval? = .default
    ) where SpecificError: Swift.Error, SpecificError: Equatable {
        toBlocking(timeout: timeout).expectToThrow(error: expectedError)
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
                timeout: timeout,
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
        timeout: TimeInterval? = .default,
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
        error expectedError: SpecificError
    )
        where
        SpecificError: Swift.Error,
        SpecificError: Equatable
    {
        switch materialize() {
        case .completed: return XCTFail("Expected error, but got `completed` instead")
        case .failed(_, let anyError):
        guard let error = anyError as? SpecificError else {
            return XCTFail("Got error as expected, but it has the wrong type, got error:\n<\(anyError)>\n, but expected error:\n<\(expectedError)>\n")
        }
        XCTAssertEqual(error, expectedError)
        }
    }
    
    
    func expectToThrowRPCErrorUnrecognizedJson<SpecificError>(
        expectedErrorType: SpecificError.Type,
        containingString expectedSubStringInUnrecognizedStringError: String,
        function: String = #function,
        file: String = #file,
        line: Int = #line,
        deriveUnreconizedJsonError: (SpecificError) -> String?
    ) where SpecificError: Swift.Error {
        
        let description = "\(function) in \(file), at line: \(line)"
        
        switch materialize() {
        case .completed: return XCTFail("Expected error, but got `completed` instead")
        case .failed(_, let anyError):
            guard let error = anyError as? SpecificError else {
                return XCTFail("Got error as expected, but it has the wrong type, got error:\n<\(anyError)>\n, but expected type:\n<\(SpecificError.self)>\n")
            }
            
            guard let deriveUnreconizedJsonStringFromError = deriveUnreconizedJsonError(error) else {
                return XCTFail("Could not derive any <unreconized JSON string> from error: `\(error)`, but expected one")
            }
            XCTAssertTrue(deriveUnreconizedJsonStringFromError.contains(expectedSubStringInUnrecognizedStringError),
                          "Test \(description) failed, `deriveUnreconizedJsonStringFromError`: \(deriveUnreconizedJsonStringFromError) DID NOT contain `expectedSubStringInUnrecognizedStringError`: \(expectedSubStringInUnrecognizedStringError)"
            )
            
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
