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
        timeout: RxTimeInterval? = 2,
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

extension Observable {
    
    func blockingAssertThrows<SpecificError>(
        error expectedError: SpecificError,
        timeout: RxTimeInterval? = 2
    ) where SpecificError: Swift.Error, SpecificError: Equatable {
        toBlocking(timeout: timeout).expectToThrow(error: expectedError)
    }
    
    func blockingTakeFirst(
        _ takeCount: Int = 1,
        timeout: RxTimeInterval? = 2,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
        ) -> E? {
        
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
        timeout: RxTimeInterval? = 2,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
        ) -> E? {
        
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
        timeout: RxTimeInterval? = 2,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
        ) -> E? {
        return take(takeCount)
            .toBlocking(timeout: timeout)
            .getElement(
                at: takeElementAt,
                timeout: timeout,
                failOnTimeout: failOnTimeout && isConnectedToLocalhost(),
                failOnNil: failOnNil,
                function: function,
                file: file,
                line: line
        )
    }
    
    func blockingArrayTakeFirst(
        _ takeCount: Int = 1,
        timeout: RxTimeInterval? = 2,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> [E]? {
        
        return take(takeCount)
            .toBlocking(timeout: timeout)
            .getArray(
                timeout: timeout,
                failOnTimeout: failOnTimeout && isConnectedToLocalhost(),
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

private extension BlockingObservable {
    func getElement(
        at getElementAt: ElementAt = .first,
        timeout: RxTimeInterval? = 2,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
    ) -> E? {
        let description = "\(function) in \(file), at line: \(line)"
        do {
            let element: E?
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
        ) where SpecificError: Swift.Error, SpecificError: Equatable {
        switch materialize() {
        case .completed: return XCTFail("Expected error, but got `completed` instead")
        case .failed(_, let anyError):
        guard let error = anyError as? SpecificError else {
            return XCTFail("Got error as expected, but it has the wrong type, got error: \(anyError)")
        }
        XCTAssertEqual(error, expectedError)
        }
    }
    
    func getArray(
        timeout: RxTimeInterval? = 2,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file,
        line: Int = #line
        ) -> [E]? {
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
