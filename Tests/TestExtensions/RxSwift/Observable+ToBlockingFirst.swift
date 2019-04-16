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
    
    // Sometimes an interval of `1` results in timeout...
    func blockingTakeFirst(timeout: RxTimeInterval = 2, failOnTimeoutOrNil: Bool? = nil) -> E? {
        let failOnTimeoutOrNil = failOnTimeoutOrNil ?? isConnectedToLocalhost
        // `take()` operator is absolutely crucial, read "Waiting on non-completing sequences": http://rx-marin.com/post/rxblocking-part1/
        let blocked = take(1).toBlocking(timeout: timeout)
        let optionalFirst: E?
        do {
            optionalFirst = try blocked.first()
        } catch {
            if failOnTimeoutOrNil {
                XCTFail("Error: \(error)")
            }
            return nil
        }
        
        guard let element = optionalFirst else {
            if failOnTimeoutOrNil {
                XCTFail("Element is nil")
            }
            return nil
        }
        return element
    }
    
    // Sometimes an interval of `1` results in timeout...
    func blockingArrayTakeFirst(_ takeCount: Int = 1, timeout: RxTimeInterval = 2, failOnTimeoutOrNil: Bool? = nil) -> [E]? {
        let failOnTimeoutOrNil = failOnTimeoutOrNil ?? isConnectedToLocalhost
        // `take()` operator is absolutely crucial, read "Waiting on non-completing sequences": http://rx-marin.com/post/rxblocking-part1/
        let blocked = take(takeCount).toBlocking(timeout: timeout)
        let optionalArray: [E]?
        do {
            optionalArray = try blocked.toArray()
        } catch {
            if failOnTimeoutOrNil {
                XCTFail("Error: \(error)")
            }
            return nil
        }
        
        guard let element = optionalArray else {
            if failOnTimeoutOrNil {
                XCTFail("Element is nil")
            }
            return nil
        }
        return element
    }
}
