/// MIT License
/// 
/// Copyright (c) 2019 Radix DLT - https://radixdlt.com
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in all
/// copies or substantial portions of the Software.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
/// SOFTWARE.

import Foundation

import XCTest
import RxTest
import RxBlocking
import RxSwift

extension RxTimeInterval {
    static var enoughForPOW: RxTimeInterval {
        return RxTimeInterval.seconds(8)
    }
    
    static var `default`: RxTimeInterval {
        return RxTimeInterval.seconds(2)
    }
}

extension TestScheduler {
    
    typealias ObservableHandler<Element> = (Observable<Element>) -> Void

    /// Run the simulation and record all events using observer returned by this function.
    /// Subscribe at virtual time 0
    /// Dispose subscription at virtual time 1000
    func start<Element>(
        created: TestTime = 0,
        subscribed: TestTime = 0,
        disposed: TestTime = 1000,
        createRecored: @escaping () -> TestableObservable<Element>,
        observableHandler: ObservableHandler<Element>? = nil
        ) -> TestableObserver<Element> {

        return self.start(created: created, subscribed: subscribed, disposed: disposed) {
            let observables = createRecored().asObservable()
            observableHandler?(observables)
            return observables
        }

    }

    /// Run the simulation and record all events using observer returned by this function.
    /// Subscribe at virtual time 0
    /// Dispose subscription at virtual time 1000
    func start<Element>(
        created: TestTime = 0,
        subscribed: TestTime = 0,
        disposed: TestTime = 1000,
        type: CreateHotOrCold = .hot,
        recorded recordedEvents: [Recorded<Event<Element>>],
        observableHandler: ObservableHandler<Element>? = nil
        ) -> TestableObserver<Element> {

        return self.start(
            created: created,
            subscribed: subscribed,
            disposed: disposed,
            createRecored: {
                type.create(scheduler: self, recordedEvents: recordedEvents)
        }, observableHandler: observableHandler)
    }

    static func schedule<Element>(
        initialClock: TestTime = 0,
        created: TestTime = 0,
        subscribed: TestTime = 0,
        disposed: TestTime = 1000,
        type: CreateHotOrCold = .hot,
        recorded recordedEvents: [Recorded<Event<Element>>],
        observableHandler: ObservableHandler<Element>? = nil
    ) -> TestableObserver<Element> {
        
        return TestScheduler(initialClock: initialClock).start(
            created: created,
            subscribed: subscribed,
            disposed: disposed,
            type: type,
            recorded: recordedEvents,
            observableHandler: observableHandler
        )
    }
        
    enum CreateHotOrCold {
        case hot, cold
        func create<Element>(scheduler: TestScheduler, recordedEvents: [Recorded<Event<Element>>]) -> TestableObservable<Element> {
            switch self {
            case .cold: return scheduler.createColdObservable(recordedEvents)
            case .hot: return scheduler.createHotObservable(recordedEvents)
            }
        }
    }
}
