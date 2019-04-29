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

extension Observable {
    
    func blockingTakeFirst(
        timeout: RxTimeInterval? = 2,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file
    ) -> E? {
        
        return take(1)
            .toBlocking(timeout: timeout)
            .getFirstElement(
                timeout: timeout,
                failOnTimeout: failOnTimeout && isConnectedToLocalhost(),
                failOnNil: failOnNil,
                function: function,
                file: file
        )
    }
    
    func blockingArrayTakeFirst(
        _ takeCount: Int = 1,
        timeout: RxTimeInterval? = 2,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file
    ) -> [E]? {
        
        return take(takeCount)
            .toBlocking(timeout: timeout)
            .getArray(
                timeout: timeout,
                failOnTimeout: failOnTimeout && isConnectedToLocalhost(),
                failOnNil: failOnNil,
                function: function,
                file: file
            )
        
    }
}

private extension BlockingObservable {
    func getFirstElement(
        timeout: RxTimeInterval? = 2,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file
    ) -> E? {
        let description = "\(function) in \(file)"
        do {
            let element = try self.first()
            if failOnNil {
                XCTAssertNotNil(element, "Element should not be nil, \(description)")
            }
            return element
        } catch RxError.timeout {
            if failOnTimeout {
                XCTFail("Timeout, \(description)")
            }
            return nil
        } catch {
            fatalError("Unexpected error thrown: \(error)")
        }
    }
    
    func getArray(
        timeout: RxTimeInterval? = 2,
        failOnTimeout: Bool = true,
        failOnNil: Bool = true,
        function: String = #function,
        file: String = #file
        ) -> [E]? {
        let description = "\(function) in \(file)"
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
            fatalError("Unexpected error thrown: \(error)")
        }
    }
}
