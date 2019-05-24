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

extension Observable {
    
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
